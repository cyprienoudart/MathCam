"""
Tests for the MathCam solver module.

Tests cover:
- Configuration loading
- Response parsing (STEPS/ANSWER format + fallback)
- Health check
- End-to-end solving (requires Ollama running with qwen2-math:7b)
"""

import os
import pytest
from solver.config import SolverConfig
from solver.solver import MathSolver, MathSolution
from solver.prompts import MATH_SOLVER_SYSTEM_PROMPT, build_user_prompt


# ---------------------------------------------------------------------------
# Config tests
# ---------------------------------------------------------------------------

class TestConfig:
    def test_default_values(self):
        config = SolverConfig()
        assert config.model == "qwen2-math:7b"
        assert config.ollama_host == "http://localhost:11434"
        assert config.temperature == 0.1
        assert config.max_tokens == 2048

    def test_env_override(self, monkeypatch):
        monkeypatch.setenv("MATHCAM_MODEL", "phi3:mini")
        monkeypatch.setenv("MATHCAM_TEMPERATURE", "0.5")
        config = SolverConfig()
        assert config.model == "phi3:mini"
        assert config.temperature == 0.5


# ---------------------------------------------------------------------------
# Prompt tests
# ---------------------------------------------------------------------------

class TestPrompts:
    def test_system_prompt_has_structure(self):
        assert "STEPS:" in MATH_SOLVER_SYSTEM_PROMPT
        assert "ANSWER:" in MATH_SOLVER_SYSTEM_PROMPT

    def test_system_prompt_covers_math_domains(self):
        domains = [
            "Arithmetic", "Algebra", "Logarithms", "Exponentials",
            "Trigonometry", "Calculus", "Geometry", "Combinatorics",
        ]
        for domain in domains:
            assert domain in MATH_SOLVER_SYSTEM_PROMPT, f"Missing domain: {domain}"

    def test_user_prompt_format(self):
        prompt = build_user_prompt("2x + 5 = 13")
        assert "2x + 5 = 13" in prompt
        assert "Solve" in prompt


# ---------------------------------------------------------------------------
# Response parsing tests (no Ollama needed)
# ---------------------------------------------------------------------------

class TestParsing:
    def setup_method(self):
        self.solver = MathSolver.__new__(MathSolver)
        self.solver.config = SolverConfig()

    def test_parse_structured_response(self):
        raw = """STEPS:
1. Subtract 5 from both sides: 2x = 8
2. Divide both sides by 2: x = 4

ANSWER: x = 4"""
        result = self.solver._parse_response("2x + 5 = 13", raw)
        assert result.answer == "x = 4"
        assert len(result.steps) == 2
        assert "Subtract 5" in result.steps[0]

    def test_parse_boxed_answer(self):
        raw = r"""To solve, we subtract 5 and divide by 2.
\boxed{4}"""
        result = self.solver._parse_response("2x + 5 = 13", raw)
        assert result.answer == "4"

    def test_parse_freeform(self):
        raw = """First, subtract 5 from both sides to get 2x = 8.

Then, divide both sides by 2 to get x = 4.

The answer is 4."""
        result = self.solver._parse_response("2x + 5 = 13", raw)
        assert len(result.steps) > 0
        assert result.problem == "2x + 5 = 13"

    def test_parse_empty_response(self):
        result = self.solver._parse_response("2+2", "")
        assert result.answer  # Should have some fallback


# ---------------------------------------------------------------------------
# Health check test
# ---------------------------------------------------------------------------

class TestHealth:
    def test_health_check(self):
        """Requires Ollama to be running."""
        solver = MathSolver()
        healthy = solver.is_healthy()
        assert healthy, (
            "Ollama health check failed. "
            "Make sure Ollama is running (ollama serve) "
            "and qwen2-math:7b is pulled."
        )


# ---------------------------------------------------------------------------
# End-to-end tests (require Ollama running + model pulled)
# ---------------------------------------------------------------------------

class TestSolveE2E:
    """These tests call the actual LLM and take ~5-15 seconds each."""

    def setup_method(self):
        self.solver = MathSolver()

    def test_simple_arithmetic(self):
        result = self.solver.solve("What is 15 * 7 + 23?")
        assert result.answer
        assert "128" in result.answer
        assert len(result.steps) > 0

    def test_equation(self):
        result = self.solver.solve("Solve for x: 3x - 9 = 0")
        assert result.answer
        assert "3" in result.answer

    def test_inequality(self):
        result = self.solver.solve("Solve: x^2 - 4 < 0")
        assert result.answer
        assert len(result.steps) > 0

    def test_logarithm(self):
        result = self.solver.solve("Simplify: ln(e^3) + log_2(16)")
        assert result.answer
        assert "7" in result.answer

    def test_derivative(self):
        result = self.solver.solve("Find the derivative of f(x) = x^3 + 2x^2 - 5x + 1")
        assert result.answer
        assert len(result.steps) > 0
