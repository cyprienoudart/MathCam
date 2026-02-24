#!/usr/bin/env python3
"""
MathCam Benchmark — Score the solver across math domains.

Usage:
    cd backend
    python3 benchmark.py                    # Run with default model
    MATHCAM_MODEL=mathcam python3 benchmark.py  # Run with custom model

Runs a battery of math problems, checks answers, and produces a score report.
"""

import sys
import os
import time
import re

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from solver import MathSolver
from solver.config import SolverConfig


# ── ANSI colors ──────────────────────────────────────────────────────────────

BOLD = "\033[1m"
DIM = "\033[2m"
RESET = "\033[0m"
GREEN = "\033[32m"
RED = "\033[31m"
YELLOW = "\033[33m"
CYAN = "\033[36m"
MAGENTA = "\033[35m"


# ── Benchmark problems ──────────────────────────────────────────────────────
# Each: (domain, problem, expected_keywords_in_answer)
# We check if ANY of the keywords appear in the answer (case-insensitive).

BENCHMARK_PROBLEMS = [
    # --- Arithmetic ---
    ("Arithmetic", "What is 15 * 7 + 23?", ["128"]),
    ("Arithmetic", "What is 1024 / 16?", ["64"]),
    ("Arithmetic", "What is 17 mod 5?", ["2"]),

    # --- Algebra ---
    ("Algebra", "Solve for x: 5x - 3 = 22", ["5", "x = 5"]),
    ("Algebra", "Solve: x^2 - 5x + 6 = 0", ["2", "3"]),
    ("Algebra", "Solve the system: x + y = 10, x - y = 4", ["7", "3"]),

    # --- Powers & Roots ---
    ("Powers & Roots", "What is 2^10?", ["1024"]),
    ("Powers & Roots", "What is sqrt(256)?", ["16"]),
    ("Powers & Roots", "Simplify: 27^(1/3)", ["3"]),

    # --- Logarithms ---
    ("Logarithms", "What is ln(e^7)?", ["7"]),
    ("Logarithms", "What is log_2(64)?", ["6"]),
    ("Logarithms", "Simplify: log_10(1000) + ln(1)", ["3"]),

    # --- Exponentials ---
    ("Exponentials", "If f(x) = e^(2x), what is f(0)?", ["1"]),
    ("Exponentials", "Solve: e^x = 20", ["ln(20)", "2.99", "3.0", "ln 20"]),

    # --- Trigonometry ---
    ("Trigonometry", "What is sin(pi/6)?", ["1/2", "0.5"]),
    ("Trigonometry", "What is cos(0)?", ["1"]),
    ("Trigonometry", "Simplify: sin^2(x) + cos^2(x)", ["1"]),

    # --- Calculus: Derivatives ---
    ("Derivatives", "Find the derivative of f(x) = x^4", ["4x^3", "4*x^3"]),
    ("Derivatives", "Find the derivative of f(x) = sin(x)", ["cos(x)", "cos x"]),
    ("Derivatives", "Find the derivative of f(x) = ln(x)", ["1/x"]),
    ("Derivatives", "Find the derivative of f(x) = e^(3x)", ["3e^(3x)", "3*e^(3x)", "3e^3x"]),

    # --- Calculus: Integrals ---
    ("Integrals", "What is the integral of 2x dx?", ["x^2", "x**2"]),
    ("Integrals", "What is the integral of cos(x) dx?", ["sin(x)", "sin x"]),
    ("Integrals", "Evaluate the definite integral of x from 0 to 4", ["8"]),

    # --- Inequalities ---
    ("Inequalities", "Solve: 3x + 1 > 10", ["x > 3", "3"]),
    ("Inequalities", "Solve: x^2 - 9 <= 0", ["[-3, 3]", "-3", "3"]),

    # --- Geometry ---
    ("Geometry", "What is the area of a circle with radius 5?", ["25pi", "25*pi", "25π", "78.5"]),
    ("Geometry", "A right triangle has legs 3 and 4. What is the hypotenuse?", ["5"]),

    # --- Combinatorics ---
    ("Combinatorics", "What is 10! / (8! * 2!)?", ["45"]),
    ("Combinatorics", "How many ways to choose 3 items from 7?", ["35"]),

    # --- Word Problems ---
    ("Word Problem", "A car travels 180 km in 3 hours. What is its speed in km/h?", ["60"]),
    ("Word Problem", "If 3 apples cost $2.40, how much do 7 apples cost?", ["5.60", "5.6", "$5.60"]),
]


def check_answer(answer: str, expected_keywords: list[str]) -> bool:
    """Check if the answer contains any expected keyword."""
    answer_lower = answer.lower().replace(" ", "")
    for kw in expected_keywords:
        if kw.lower().replace(" ", "") in answer_lower:
            return True
    return False


def run_benchmark():
    config = SolverConfig()
    solver = MathSolver(config)

    print(f"\n{CYAN}{BOLD}{'=' * 65}")
    print(f"  🧮  MathCam Benchmark — Model: {config.model}")
    print(f"{'=' * 65}{RESET}\n")

    if not solver.is_healthy():
        print(f"{RED}❌ Cannot connect to Ollama or model not available.{RESET}")
        sys.exit(1)

    results = {}  # domain -> (pass, total)
    total_pass = 0
    total_count = 0
    failed_problems = []

    for domain, problem, expected in BENCHMARK_PROBLEMS:
        total_count += 1

        # Initialize domain counter
        if domain not in results:
            results[domain] = [0, 0]
        results[domain][1] += 1

        # Solve
        start = time.time()
        try:
            solution = solver.solve(problem)
            elapsed = time.time() - start
            passed = check_answer(solution.answer, expected)

            if passed:
                total_pass += 1
                results[domain][0] += 1
                icon = f"{GREEN}✅{RESET}"
            else:
                icon = f"{RED}❌{RESET}"
                failed_problems.append((domain, problem, expected, solution.answer))

            print(
                f"  {icon} {DIM}[{domain}]{RESET} {problem[:50]:50s} "
                f"→ {BOLD}{solution.answer[:30]}{RESET} {DIM}({elapsed:.1f}s){RESET}"
            )
        except Exception as e:
            results[domain][1] += 0  # Already counted
            failed_problems.append((domain, problem, expected, f"ERROR: {e}"))
            print(f"  {RED}❌{RESET} {DIM}[{domain}]{RESET} {problem[:50]:50s} → {RED}ERROR{RESET}")

    # ── Summary ──────────────────────────────────────────────────────────
    print(f"\n{CYAN}{BOLD}{'=' * 65}")
    print(f"  📊  Results")
    print(f"{'=' * 65}{RESET}\n")

    for domain, (p, t) in sorted(results.items()):
        pct = (p / t * 100) if t > 0 else 0
        bar_len = int(pct / 5)
        bar = "█" * bar_len + "░" * (20 - bar_len)
        color = GREEN if pct >= 80 else YELLOW if pct >= 50 else RED
        print(f"  {domain:25s} {color}{bar} {p}/{t} ({pct:.0f}%){RESET}")

    overall_pct = (total_pass / total_count * 100) if total_count > 0 else 0
    color = GREEN if overall_pct >= 80 else YELLOW if overall_pct >= 50 else RED
    print(f"\n  {BOLD}{'─' * 55}{RESET}")
    print(f"  {BOLD}Overall: {color}{total_pass}/{total_count} ({overall_pct:.0f}%){RESET}\n")

    # Show failures
    if failed_problems:
        print(f"\n  {RED}{BOLD}Failed problems:{RESET}")
        for domain, problem, expected, got in failed_problems:
            print(f"    {DIM}[{domain}]{RESET} {problem}")
            print(f"      Expected keywords: {expected}")
            print(f"      Got: {got}")
            print()


if __name__ == "__main__":
    run_benchmark()
