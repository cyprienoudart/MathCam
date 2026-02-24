"""
MathCam Solver — Local LLM-powered math solving engine.

Uses Ollama to run an open-weight math model locally.
No cloud APIs, no costs, runs entirely on your machine.
"""

from solver.solver import MathSolver, MathSolution
from solver.config import SolverConfig

__all__ = ["MathSolver", "MathSolution", "SolverConfig"]
