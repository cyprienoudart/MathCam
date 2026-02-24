#!/usr/bin/env python3
"""
Script de test pour le module OCR de MathCam.
Permet de tester la reconnaissance d'équations à partir d'un fichier image.

Usage:
    python test_ocr.py <chemin_vers_image>
    python test_ocr.py <chemin_vers_image> --latex   # Afficher aussi le LaTeX brut

Exemples:
    python test_ocr.py equation.png
    python test_ocr.py photo_maths.jpg --latex
"""

import sys
import os

# Ajouter le chemin du projet
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from ml_models.ocr.image_processor import (
    extract_equation_from_path,
    extract_latex_from_path,
    latex_to_plaintext,
)


def test_latex_converter():
    """Tests unitaires pour la conversion LaTeX → texte."""
    test_cases = [
        (r"\frac{2x+3}{5} = 7", "(2*x+3)/(5) = 7"),
        (r"x^{2} + 3x - 5 = 0", "x**(2) + 3*x - 5 = 0"),
        (r"\sqrt{x+1} = 4", "sqrt(x+1) = 4"),
        (r"2 \cdot x + 1", "2*x + 1"),
        (r"3 \times 5", "3*5"),
        (r"\frac{1}{2}", "(1)/(2)"),
        (r"x^2 + y^2 = r^2", "x**2 + y**2 = r**2"),
        (r"\pi r^{2}", "pi*r**(2)"),
        (r"\sqrt[3]{8}", "(8)**(1/(3))"),
        (r"2x + 3 = 7", "2*x + 3 = 7"),
        (r"\sin(x) + \cos(x)", "sin(x) + cos(x)"),
        (r"x \leq 5", "x <= 5"),
        (r"x \geq 0", "x >= 0"),
    ]

    print("=" * 60)
    print("Tests de conversion LaTeX → texte")
    print("=" * 60)

    passed = 0
    failed = 0

    for latex_input, expected in test_cases:
        result = latex_to_plaintext(latex_input)
        ok = result == expected
        status = "✓" if ok else "✗"

        if ok:
            passed += 1
        else:
            failed += 1

        print(f"  {status}  {latex_input!r}")
        if not ok:
            print(f"       Attendu:  {expected!r}")
            print(f"       Obtenu:   {result!r}")

    print(f"\n  Résultat: {passed}/{passed + failed} tests passés\n")
    return failed == 0


def test_ocr_on_image(image_path: str, show_latex: bool = False):
    """Teste l'OCR sur une image donnée."""
    print("=" * 60)
    print(f"Test OCR sur: {image_path}")
    print("=" * 60)

    if not os.path.exists(image_path):
        print(f"  ✗ Fichier non trouvé: {image_path}")
        return False

    try:
        if show_latex:
            latex = extract_latex_from_path(image_path)
            print(f"  LaTeX brut:    {latex}")

        equation = extract_equation_from_path(image_path)
        print(f"  Équation:      {equation}")
        print(f"  ✓ Reconnaissance réussie")
        return True

    except Exception as e:
        print(f"  ✗ Erreur: {e}")
        return False


if __name__ == "__main__":
    # Toujours lancer les tests du convertisseur LaTeX
    converter_ok = test_latex_converter()

    # Si un fichier image est fourni, tester l'OCR dessus
    if len(sys.argv) >= 2:
        image_path = sys.argv[1]
        show_latex = "--latex" in sys.argv
        test_ocr_on_image(image_path, show_latex)
    else:
        print("Pour tester l'OCR sur une image:")
        print(f"  python {sys.argv[0]} <chemin_image> [--latex]")

    if not converter_ok:
        sys.exit(1)
