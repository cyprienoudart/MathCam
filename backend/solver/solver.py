"""
MathSolver — Main solver logic.

Sends math problems to a local Ollama model, parses the structured response
into steps + answer.
"""

import re
import logging

from pydantic import BaseModel
from ollama import Client, ResponseError

from solver.config import SolverConfig
from solver.prompts import MATH_SOLVER_SYSTEM_PROMPT, build_user_prompt

logger = logging.getLogger(__name__)


class MathSolution(BaseModel):
    """Structured math solution returned by the solver."""

    problem: str  # Original problem text
    steps: list[str]  # Step-by-step reasoning
    answer: str  # Final answer


class MathSolver:
    """Local LLM-powered math solver using Ollama.

    Usage:
        solver = MathSolver()
        solution = solver.solve("2x + 5 = 13")
        print(solution.answer)  # "x = 4"
    """

    def __init__(self, config: SolverConfig | None = None):
        self.config = config or SolverConfig()
        self._client = Client(host=self.config.ollama_host)

    def solve(self, problem: str) -> MathSolution:
        """Solve a math problem using the local LLM.

        Args:
            problem: Math problem as a string (from OCR or keyboard input).

        Returns:
            MathSolution with steps and final answer.

        Raises:
            ConnectionError: If Ollama is not running.
            RuntimeError: If the model fails to generate a response.
        """
        logger.info("Solving: %s (model=%s)", problem, self.config.model)

        try:
            response = self._client.chat(
                model=self.config.model,
                messages=[
                    {"role": "system", "content": MATH_SOLVER_SYSTEM_PROMPT},
                    {"role": "user", "content": build_user_prompt(problem)},
                ],
                options={
                    "temperature": self.config.temperature,
                    "num_predict": self.config.max_tokens,
                },
            )
        except ResponseError as e:
            logger.error("Ollama response error: %s", e)
            raise RuntimeError(f"Model error: {e}") from e
        except Exception as e:
            logger.error("Failed to connect to Ollama: %s", e)
            raise ConnectionError(
                f"Cannot connect to Ollama at {self.config.ollama_host}. "
                "Is it running? Start it with: ollama serve"
            ) from e

        raw_text = response["message"]["content"]
        logger.debug("Raw LLM response:\n%s", raw_text)

        return self._parse_response(problem, raw_text)

    def is_healthy(self) -> bool:
        """Check if Ollama is reachable and the model is available."""
        try:
            models = self._client.list()
            available = [m.model for m in models.models]
            return self.config.model in available or any(
                self.config.model in m for m in available
            )
        except Exception:
            return False

    def _parse_response(self, problem: str, raw_text: str) -> MathSolution:
        """Parse the LLM's structured response into a MathSolution.

        Handles various response formats gracefully — even if the model
        doesn't perfectly follow the STEPS:/ANSWER: format.
        """
        steps = []
        answer = ""

        # Try to extract STEPS section
        steps_match = re.search(
            r"STEPS:\s*\n(.*?)(?=\nANSWER:|\Z)",
            raw_text,
            re.DOTALL | re.IGNORECASE,
        )
        if steps_match:
            steps_text = steps_match.group(1).strip()
            # Parse numbered steps: "1. ...", "2. ...", etc.
            raw_steps = re.split(r"\n\s*\d+\.\s+", steps_text)
            steps = [s.strip() for s in raw_steps if s.strip()]

        # Try to extract ANSWER section
        answer_match = re.search(
            r"ANSWER:\s*(.*?)$",
            raw_text,
            re.DOTALL | re.IGNORECASE,
        )
        if answer_match:
            answer = answer_match.group(1).strip()

        # Fallback: if the model didn't follow the format, use the full
        # response as a single step and try to extract a \boxed{} answer
        # (Qwen2-Math often uses this format).
        if not steps and not answer:
            answer = self._extract_boxed_answer(raw_text) or raw_text.strip()
            steps = self._extract_steps_from_freeform(raw_text)
        elif not answer:
            answer = self._extract_boxed_answer(raw_text) or steps[-1] if steps else ""
        elif not steps:
            steps = self._extract_steps_from_freeform(raw_text)

        return MathSolution(
            problem=problem,
            steps=steps if steps else ["Direct computation"],
            answer=answer if answer else "Could not determine answer",
        )

    @staticmethod
    def _extract_boxed_answer(text: str) -> str | None:
        """Extract answer from \\boxed{...} format (common in math models)."""
        match = re.search(r"\\boxed\{([^}]+)\}", text)
        if match:
            return match.group(1).strip()
        return None

    @staticmethod
    def _extract_steps_from_freeform(text: str) -> list[str]:
        """Extract reasoning steps from free-form text with numbered items or bold headers."""
        steps = []

        # Try numbered patterns: "1. ...", "Step 1: ...", etc.
        numbered = re.findall(
            r"(?:^|\n)\s*(?:\d+\.\s+|\*\*(?:Step\s+)?\d+[:.]\*\*\s*)(.*?)(?=\n\s*(?:\d+\.\s+|\*\*(?:Step\s+)?\d+)|\nANSWER:|\n\\boxed|\Z)",
            text,
            re.DOTALL,
        )
        if numbered:
            steps = [s.strip().replace("\n", " ") for s in numbered if s.strip()]

        # Fallback: split by paragraphs if no numbered steps found
        if not steps:
            paragraphs = text.split("\n\n")
            steps = [
                p.strip().replace("\n", " ")
                for p in paragraphs
                if p.strip() and "\\boxed" not in p
            ]

        return steps[:20]  # Cap at 20 steps to avoid runaway output
