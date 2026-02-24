import io
import re
import cv2
import numpy as np
from PIL import Image, ImageOps, ExifTags
from pix2tex.cli import LatexOCR

# ──────────────────────────────────────────────
# Module OCR pour MathCam
# Traite les images d'entrée et extrait les équations mathématiques
# via le modèle pix2tex (LaTeX OCR)
# ──────────────────────────────────────────────

# Lazy-loaded model singleton (avoids slow startup)
_model = None


def _get_model():
    """
    Charge le modèle LatexOCR de manière paresseuse (lazy loading).
    Le modèle est téléchargé automatiquement lors du premier appel (~400 Mo).
    """
    global _model
    if _model is None:
        _model = LatexOCR()
    return _model


# ──────────────────────────────────────────────
# PUBLIC API
# ──────────────────────────────────────────────

async def extract_equation(image_file):
    """
    Extrait une équation mathématique à partir d'une image en utilisant pix2tex OCR.

    Args:
        image_file: Le fichier image téléchargé (FastAPI UploadFile) contenant l'équation

    Returns:
        str: L'équation mathématique extraite sous forme de texte lisible par SymPy
    """
    try:
        # Lire l'image en mémoire via PIL (gère l'orientation EXIF des photos)
        contents = await image_file.read()
        pil_img = Image.open(io.BytesIO(contents))

        # Appliquer la rotation EXIF (photos prises avec un téléphone)
        pil_img = ImageOps.exif_transpose(pil_img)

        if pil_img is None:
            raise ValueError("Impossible de décoder l'image fournie")

        # Prétraitement de l'image
        pil_img = preprocess_image(pil_img)

        # Reconnaissance via pix2tex → LaTeX
        model = _get_model()
        latex = model(pil_img)

        # Convertir LaTeX en texte lisible pour le solveur
        equation = latex_to_plaintext(latex)

        return equation

    except Exception as e:
        raise Exception(f"Erreur lors du traitement de l'image: {str(e)}")


def extract_equation_from_path(image_path: str) -> str:
    """
    Variante synchrone qui accepte un chemin de fichier.
    Utile pour les tests et l'utilisation en ligne de commande.

    Args:
        image_path: Chemin vers le fichier image

    Returns:
        str: L'équation mathématique extraite
    """
    pil_img = Image.open(image_path)
    pil_img = ImageOps.exif_transpose(pil_img)

    pil_img = preprocess_image(pil_img)

    model = _get_model()
    latex = model(pil_img)

    equation = latex_to_plaintext(latex)
    return equation


def extract_latex_from_path(image_path: str) -> str:
    """
    Extrait l'équation en LaTeX brut (sans conversion en texte).
    Utile pour le débogage ou l'affichage.

    Args:
        image_path: Chemin vers le fichier image

    Returns:
        str: L'équation en notation LaTeX
    """
    pil_img = Image.open(image_path)
    pil_img = ImageOps.exif_transpose(pil_img)

    pil_img = preprocess_image(pil_img)

    model = _get_model()
    latex = model(pil_img)
    return latex


# ──────────────────────────────────────────────
# IMAGE PREPROCESSING
# ──────────────────────────────────────────────

def preprocess_image(pil_img):
    """
    Prétraite l'image PIL pour améliorer la reconnaissance de caractères.
    Utilise un traitement doux adapté à l'écriture manuscrite.
    Retourne une image PIL prête pour pix2tex.
    """
    # Convertir en niveaux de gris
    gray = pil_img.convert('L')

    # Convertir en numpy pour le traitement OpenCV
    img_np = np.array(gray)

    # Léger débruitage (préserve les traits d'écriture)
    denoised = cv2.fastNlMeansDenoising(img_np, None, h=10, templateWindowSize=7, searchWindowSize=21)

    # Améliorer le contraste via CLAHE (adaptatif)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    enhanced = clahe.apply(denoised)

    # Binarisation Otsu (meilleur que adaptiveThreshold pour l'écriture)
    _, binary = cv2.threshold(enhanced, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

    # Recadrer en supprimant les grandes marges blanches
    binary = _auto_crop(binary, margin=20)

    # Reconvertir en PIL Image (RGB car pix2tex attend du RGB)
    result = Image.fromarray(binary).convert('RGB')
    return result


def _auto_crop(binary_img, margin=20):
    """
    Recadre l'image en supprimant les grandes marges blanches autour du contenu.
    Ajoute une petite marge uniforme autour du contenu détecté.
    """
    # Inverser pour trouver les pixels de contenu (noirs → blancs)
    inverted = cv2.bitwise_not(binary_img)

    # Trouver les coordonnées du contenu non-blanc
    coords = cv2.findNonZero(inverted)
    if coords is None:
        return binary_img  # Pas de contenu trouvé

    x, y, w, h = cv2.boundingRect(coords)

    # Ajouter une marge autour
    rows, cols = binary_img.shape
    x1 = max(0, x - margin)
    y1 = max(0, y - margin)
    x2 = min(cols, x + w + margin)
    y2 = min(rows, y + h + margin)

    return binary_img[y1:y2, x1:x2]


# ──────────────────────────────────────────────
# LATEX → PLAINTEXT CONVERSION
# ──────────────────────────────────────────────

def latex_to_plaintext(latex: str) -> str:
    """
    Convertit une chaîne LaTeX en texte lisible par le solveur SymPy.

    Exemples:
        \\frac{2x+3}{5} = 7      →  (2*x+3)/(5) = 7
        x^{2} + 3x - 5 = 0      →  x**2 + 3*x - 5 = 0
        \\sqrt{x+1} = 4          →  sqrt(x+1) = 4
        2 \\cdot x + 1           →  2*x + 1
        3 \\times 5              →  3*5
        \\pi r^{2}               →  pi*r**2
    """
    s = latex.strip()

    # Supprimer les délimiteurs LaTeX math mode
    s = s.replace('$', '')
    s = re.sub(r'\\left\s*', '', s)
    s = re.sub(r'\\right\s*', '', s)
    s = re.sub(r'\\displaystyle\s*', '', s)
    s = re.sub(r'\\textstyle\s*', '', s)

    # ── Nettoyage préliminaire des commandes de formatage ──
    s = re.sub(r'\\scriptstyle\s*', '', s)
    s = re.sub(r'\\mathbf\s*', '', s)
    s = re.sub(r'\\mathrm\s*', '', s)
    s = re.sub(r'\\mathit\s*', '', s)
    s = re.sub(r'\\text\s*', '', s)

    # ── Fractions ──
    # \frac{num}{den} → (num)/(den)
    # Boucle avec garde anti-boucle infinie (max 10 itérations)
    max_iter = 10
    while r'\frac' in s and max_iter > 0:
        prev = s
        s = re.sub(
            r'\\frac\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}',
            r'(\1)/(\2)',
            s
        )
        max_iter -= 1
        if s == prev:
            # La regex n'a rien changé, \frac restant est malformé
            s = s.replace(r'\frac', '')
            break

    # ── Racines ──
    # \sqrt[n]{expr} → (expr)**(1/(n))
    s = re.sub(
        r'\\sqrt\s*\[([^\]]+)\]\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}',
        r'(\2)**(1/(\1))',
        s
    )
    # \sqrt{expr} → sqrt(expr)
    s = re.sub(
        r'\\sqrt\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}',
        r'sqrt(\1)',
        s
    )

    # ── Exposants ──
    # x^{expr} → x**(expr)
    s = re.sub(
        r'\^\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}',
        r'**(\1)',
        s
    )
    # x^n (single char exponent) → x**n
    s = re.sub(r'\^\s*([0-9a-zA-Z])', r'**\1', s)

    # ── Indices (subscripts) ── on les supprime pour simplifier
    s = re.sub(r'_\s*\{[^{}]*\}', '', s)
    s = re.sub(r'_\s*[0-9a-zA-Z]', '', s)

    # ── Opérateurs ──
    # Remplacer en incluant les espaces autour pour éviter des espaces parasites
    s = re.sub(r'\s*\\cdot\s*', '*', s)
    s = re.sub(r'\s*\\times\s*', '*', s)
    s = re.sub(r'\s*\\div\s*', '/', s)
    s = s.replace(r'\pm', '±')
    s = s.replace(r'\mp', '∓')
    s = s.replace(r'\leq', '<=')
    s = s.replace(r'\geq', '>=')
    s = s.replace(r'\neq', '!=')
    s = s.replace(r'\le', '<=')
    s = s.replace(r'\ge', '>=')
    s = s.replace(r'\lt', '<')
    s = s.replace(r'\gt', '>')

    # ── Constantes et fonctions ──
    s = s.replace(r'\pi', 'pi')
    s = s.replace(r'\infty', 'oo')
    s = re.sub(r'\\(sin|cos|tan|log|ln|exp|arcsin|arccos|arctan)\b', r'\1', s)
    s = re.sub(r'\\(sinh|cosh|tanh)\b', r'\1', s)

    # ── Parenthèses LaTeX ──
    s = s.replace(r'\{', '(')
    s = s.replace(r'\}', ')')
    s = s.replace('{', '(')
    s = s.replace('}', ')')

    # ── Nettoyage ──
    # Supprimer les commandes LaTeX restantes (\command)
    s = re.sub(r'\\[a-zA-Z]+', '', s)
    # Supprimer les backslashes orphelins
    s = s.replace('\\', '')

    # ── Multiplication implicite ──
    # Liste des noms de fonctions connues à ne pas couper avec *
    _FUNCTIONS = {'sqrt', 'sin', 'cos', 'tan', 'log', 'ln', 'exp',
                  'arcsin', 'arccos', 'arctan', 'sinh', 'cosh', 'tanh'}

    # Ajouter * entre un chiffre et une lettre: 2x → 2*x
    s = re.sub(r'(\d)([a-zA-Z])', r'\1*\g<2>', s)
    # Ajouter * entre une parenthèse fermante et une lettre/chiffre: )x → )*x
    s = re.sub(r'\)([a-zA-Z0-9])', r')*\1', s)
    # Ajouter * entre une lettre/chiffre et une parenthèse ouvrante: x( → x*(
    # SAUF si c'est un nom de fonction connu (sqrt, sin, cos, etc.)
    def _implicit_mult_before_paren(m):
        prefix = m.group(1)
        for fn in _FUNCTIONS:
            if prefix.endswith(fn):
                return m.group(0)  # Ne pas ajouter *
        return prefix + '*('
    s = re.sub(r'([a-zA-Z0-9]+)\(', _implicit_mult_before_paren, s)

    # Ajouter * entre deux groupes de lettres séparés par un espace: pi r → pi*r
    s = re.sub(r'([a-zA-Z])\s+([a-zA-Z])', r'\1*\2', s)

    # Nettoyer les espaces multiples
    s = re.sub(r'\s+', ' ', s).strip()

    return s


# ──────────────────────────────────────────────
# MODEL LOADING (for external use / warm-up)
# ──────────────────────────────────────────────

def load_model():
    """
    Charge le modèle OCR de manière explicite (pré-chargement).
    Appeler au démarrage du serveur pour éviter le délai au premier appel.
    """
    return _get_model()