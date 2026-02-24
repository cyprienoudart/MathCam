#!/usr/bin/env python3
"""
MathCam Interactive CLI — Test the math solver from your terminal.

Usage:
    cd backend
    python3 cli.py

Type any math problem and get step-by-step solutions.
Type 'quit' or 'exit' to stop.
"""

import sys
import os
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from solver import MathSolver, MathSolution
from solver.config import SolverConfig


# ── ANSI colors ──────────────────────────────────────────────────────────────

BOLD = "\033[1m"
DIM = "\033[2m"
RESET = "\033[0m"
CYAN = "\033[36m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
MAGENTA = "\033[35m"
RED = "\033[31m"
BLUE = "\033[34m"


def print_banner():
    print(f"""
{CYAN}{BOLD}╔══════════════════════════════════════════════════════════╗
║                  🧮  MathCam Solver  🧮                 ║
║            Local LLM Math Problem Solver                 ║
╚══════════════════════════════════════════════════════════╝{RESET}
""")


def print_solution(solution: MathSolution, elapsed: float):
    """Pretty-print a math solution."""
    print()
    print(f"  {BLUE}{BOLD}📝 Problem:{RESET} {solution.problem}")
    print()

    # Steps
    print(f"  {YELLOW}{BOLD}📐 Solution Steps:{RESET}")
    for i, step in enumerate(solution.steps, 1):
        print(f"    {DIM}{i}.{RESET} {step}")
    print()

    # Answer
    print(f"  {GREEN}{BOLD}✅ Answer:{RESET}  {GREEN}{BOLD}{solution.answer}{RESET}")
    print(f"  {DIM}⏱  Solved in {elapsed:.1f}s{RESET}")
    print()


def print_error(msg: str):
    print(f"\n  {RED}{BOLD}❌ Error:{RESET} {msg}\n")


def print_examples():
    """Print example problems the user can try."""
    examples = [
        "2x + 5 = 13",
        "x^2 - 4x + 3 = 0",
        "What is the derivative of sin(x) * e^x ?",
        "Compute the integral of x^2 from 0 to 3",
        "Simplify: ln(e^5) + log_2(16) - sqrt(81)",
        "Solve the inequality: 2x - 7 > 3",
        "A train travels 120km in 2 hours. What is its average speed?",
        "Find the determinant of the matrix [[1,2],[3,4]]",
        "What is 15! / (13! * 2!) ?",
        "Prove that the sum of angles in a triangle is 180 degrees",
    ]
    print(f"  {MAGENTA}{BOLD}💡 Example problems to try:{RESET}")
    for ex in examples:
        print(f"    {DIM}•{RESET} {ex}")
    print()


def main():
    print_banner()

    # Initialize solver
    config = SolverConfig()
    print(f"  {DIM}Model: {config.model}{RESET}")
    print(f"  {DIM}Ollama: {config.ollama_host}{RESET}")

    solver = MathSolver(config)

    # Health check
    if not solver.is_healthy():
        print_error(
            f"Cannot connect to Ollama or model '{config.model}' is not available.\n"
            f"         Make sure Ollama is running: ollama serve\n"
            f"         And the model is pulled: ollama pull {config.model}"
        )
        sys.exit(1)

    print(f"  {GREEN}✓ Connected to Ollama — model ready{RESET}\n")
    print(f"  {DIM}Type a math problem and press Enter. Type 'examples' to see suggestions.{RESET}")
    print(f"  {DIM}Type 'quit' or 'exit' to stop.{RESET}\n")
    print(f"  {'─' * 56}\n")

    while True:
        try:
            problem = input(f"  {CYAN}{BOLD}🔢 Problem:{RESET} ").strip()
        except (KeyboardInterrupt, EOFError):
            print(f"\n\n  {DIM}Goodbye! 👋{RESET}\n")
            break

        if not problem:
            continue

        if problem.lower() in ("quit", "exit", "q"):
            print(f"\n  {DIM}Goodbye! 👋{RESET}\n")
            break

        if problem.lower() in ("examples", "help", "?"):
            print_examples()
            continue

        # Solve
        start = time.time()
        try:
            solution = solver.solve(problem)
            elapsed = time.time() - start
            print_solution(solution, elapsed)
        except ConnectionError as e:
            print_error(str(e))
        except RuntimeError as e:
            print_error(str(e))
        except Exception as e:
            print_error(f"Unexpected error: {e}")

        print(f"  {'─' * 56}\n")


if __name__ == "__main__":
    main()
