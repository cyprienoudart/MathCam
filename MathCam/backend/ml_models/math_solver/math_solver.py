import sympy as sp
import re
from sympy import symbols, sqrt, pi, Rational, solve_poly_inequality, solve_rational_inequalities
from sympy import solve_univariate_inequality, S
import tensorflow as tf

# Modèle fictif pour la prédiction basée sur ML
class MathSolverML:
    def __init__(self):
        # Ici, nous chargerions un modèle ML pour améliorer la résolution
        self.model = None
        self.is_model_loaded = False
    
    def load_model(self, model_path="model.h5"):
        """Charge le modèle ML pour aider à résoudre des équations complexes."""
        try:
            # Ici nous chargerions un vrai modèle TF
            # self.model = tf.keras.models.load_model(model_path)
            self.is_model_loaded = True
            return True
        except Exception as e:
            print(f"Erreur lors du chargement du modèle: {e}")
            return False
    
    def predict(self, equation_str):
        """Utilise le ML pour améliorer la prédiction des solutions."""
        # Pour l'instant, c'est un placeholder
        return None

# Instance globale du solveur ML
ml_solver = MathSolverML()

def parse_equation(equation_str):
    """
    Parse une équation mathématique en expression SymPy
    """
    # Nettoyer l'entrée
    equation_str = equation_str.strip()
    
    # Définir les symboles
    x = symbols('x')
    
    try:
        # Parser l'expression
        expr = sp.sympify(equation_str, locals={'sqrt': sqrt, 'pi': pi, 'Rational': Rational, 'x': x})
        return expr
    except Exception as e:
        return None  # Retourne None au lieu d'un message d'erreur

def solve_equation(equation_str):
    """
    Résout une équation mathématique, inéquation ou évalue une expression
    Retourne un résultat uniquement lorsque l'équation est complète et peut être résolue
    """
    # Essayer d'abord avec le solveur ML si disponible
    if ml_solver.is_model_loaded:
        ml_solution = ml_solver.predict(equation_str)
        if ml_solution:
            return ml_solution
    
    try:
        # Vérifier s'il s'agit d'une équation ou inéquation (contient =, <, >, ≤, ≥)
        if any(op in equation_str for op in ['=', '<', '>', '≤', '≥', '<=', '>=']):
            # Traiter les inégalités
            if '<=' in equation_str or '≤' in equation_str:
                left_side, right_side = re.split('<=|≤', equation_str, 1)
                left_expr = parse_equation(left_side)
                right_expr = parse_equation(right_side)
                if left_expr is None or right_expr is None:
                    return ""  # Équation incomplète
                inequality = left_expr <= right_expr
                relation_type = '<='
            elif '>=' in equation_str or '≥' in equation_str:
                left_side, right_side = re.split('>=|≥', equation_str, 1)
                left_expr = parse_equation(left_side)
                right_expr = parse_equation(right_side)
                if left_expr is None or right_expr is None:
                    return ""  # Équation incomplète
                inequality = left_expr >= right_expr
                relation_type = '>='
            elif '<' in equation_str:
                left_side, right_side = equation_str.split('<', 1)
                left_expr = parse_equation(left_side)
                right_expr = parse_equation(right_side)
                if left_expr is None or right_expr is None:
                    return ""  # Équation incomplète
                inequality = left_expr < right_expr
                relation_type = '<'
            elif '>' in equation_str:
                left_side, right_side = equation_str.split('>', 1)
                left_expr = parse_equation(left_side)
                right_expr = parse_equation(right_side)
                if left_expr is None or right_expr is None:
                    return ""  # Équation incomplète
                inequality = left_expr > right_expr
                relation_type = '>'
            elif '=' in equation_str:
                left_side, right_side = equation_str.split('=', 1)
                left_expr = parse_equation(left_side)
                right_expr = parse_equation(right_side)
                if left_expr is None or right_expr is None:
                    return ""  # Équation incomplète
                inequality = None
                relation_type = '='
            
            # Déplacer tout du côté gauche
            if relation_type == '=':
                equation = left_expr - right_expr
            else:
                # Pour les inégalités, nous devons garder la relation
                equation = left_expr - right_expr
            
            # Résoudre pour x si x est dans l'équation
            if 'x' in str(equation):
                x = symbols('x')
                
                if relation_type == '=':
                    try:
                        solution = sp.solve(equation, x)
                        if solution:
                            # Formater joliment la solution
                            if len(solution) == 1:
                                sol_value = solution[0]
                                # Vérifier s'il s'agit d'une fraction et formater en conséquence
                                if isinstance(sol_value, sp.Rational) and not sol_value.is_integer:
                                    return f"x = {sol_value.p}/{sol_value.q}"
                                else:
                                    return f"x = {sol_value}"
                            else:
                                return f"x = {solution}"
                        else:
                            return "Aucune solution trouvée"
                    except Exception:
                        return ""  # Ne peut pas encore résoudre
                else:
                    # Résoudre l'inégalité
                    try:
                        solution = sp.solve_univariate_inequality(inequality, x)
                        return f"Solution: {solution}"
                    except Exception:
                        return ""  # Ne peut pas encore résoudre
            else:
                # S'il s'agit d'une équation sans x, vérifier si elle est vraie
                if relation_type == '=':
                    try:
                        if sp.simplify(equation) == 0:
                            return "L'équation est vraie"
                        else:
                            return "L'équation est fausse"
                    except Exception:
                        return ""  # Ne peut pas encore évaluer
                else:
                    # Pour les inégalités sans x, évaluer si vraies ou fausses
                    try:
                        result = sp.sympify(inequality)
                        if result is S.true:
                            return "L'inégalité est vraie"
                        elif result is S.false:
                            return "L'inégalité est fausse"
                        else:
                            return f"Résultat: {result}"
                    except Exception:
                        return ""  # Ne peut pas encore évaluer
        else:
            # C'est une expression, l'évaluer simplement
            expr = parse_equation(equation_str)
            if expr is None:
                return ""  # Expression incomplète
            
            try:
                result = sp.N(expr)  # Évaluation numérique
                
                # Vérifier si le résultat est proche d'un entier
                if isinstance(result, sp.Float) and abs(result - round(result)) < 1e-10:
                    result = int(round(result))
                
                # Vérifier s'il s'agit d'une fraction et formater en conséquence
                if isinstance(result, sp.Rational) and not result.is_integer:
                    return f"{result.p}/{result.q}"
                
                return str(result)
            except Exception:
                return ""  # Ne peut pas encore évaluer
    except Exception:
        return ""  # Retourner une chaîne vide au lieu d'un message d'erreur

if __name__ == "__main__":
    print("MathCam Equation Solver")
    print("Enter 'exit' to quit")
    
    while True:
        equation_str = input("\nEnter a math equation or inequality: ")
        
        if equation_str.lower() == 'exit':
            break
            
        result = solve_equation(equation_str)
        if result:  # N'imprime que s'il y a un résultat
            print(f"Result: {result}")