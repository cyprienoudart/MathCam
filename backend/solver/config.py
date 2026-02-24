"""
Solver configuration — loaded from environment variables.

Nothing is hardcoded. Change the model by setting MATHCAM_MODEL.
"""

import os
from dataclasses import dataclass, field


@dataclass
class SolverConfig:
    """Configuration for the math solver.

    All values can be overridden via environment variables.
    """

    # The Ollama model to use. Any model available via `ollama list` works.
    # Recommended: "qwen2-math:7b" (purpose-built for math)
    # Alternatives: "deepseek-r1:7b", "phi3:mini", "qwen2-math:1.5b"
    model: str = field(
        default_factory=lambda: os.getenv("MATHCAM_MODEL", "qwen2-math:7b")
    )

    # Ollama server host. Default is local.
    ollama_host: str = field(
        default_factory=lambda: os.getenv(
            "MATHCAM_OLLAMA_HOST", "http://localhost:11434"
        )
    )

    # Temperature for generation. Low = more deterministic (better for math).
    temperature: float = field(
        default_factory=lambda: float(os.getenv("MATHCAM_TEMPERATURE", "0.1"))
    )

    # Max tokens for the response. Math solutions can be verbose with steps.
    max_tokens: int = field(
        default_factory=lambda: int(os.getenv("MATHCAM_MAX_TOKENS", "2048"))
    )
