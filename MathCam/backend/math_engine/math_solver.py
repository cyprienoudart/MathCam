import sympy as sp
import re
from sympy import symbols, sqrt, pi, Rational, solve_poly_inequality, solve_rational_inequalities
from sympy import solve_univariate_inequality, S

def parse_equation(equation_str):
    """
    Parse a mathematical equation string into a SymPy expression
    """
    # Clean up the input
    equation_str = equation_str.strip()
    
    # Define symbols
    x = symbols('x')
    
    try:
        # Parse the expression
        expr = sp.sympify(equation_str, locals={'sqrt': sqrt, 'pi': pi, 'Rational': Rational, 'x': x})
        return expr
    except Exception as e:
        return None  # Return None instead of error message

def solve_equation(equation_str):
    """
    Solve a mathematical equation, inequation or evaluate an expression
    Returns result only when the equation is complete and can be solved
    """
    try:
        # Check if it's an equation or inequation (contains =, <, >, ≤, ≥)
        if any(op in equation_str for op in ['=', '<', '>', '≤', '≥', '<=', '>=']):
            # Handle inequalities
            if '<=' in equation_str or '≤' in equation_str:
                left_side, right_side = re.split('<=|≤', equation_str, 1)
                left_expr = parse_equation(left_side)
                right_expr = parse_equation(right_side)
                if left_expr is None or right_expr is None:
                    return ""  # Incomplete equation
                inequality = left_expr <= right_expr
                relation_type = '<='
            elif '>=' in equation_str or '≥' in equation_str:
                left_side, right_side = re.split('>=|≥', equation_str, 1)
                left_expr = parse_equation(left_side)
                right_expr = parse_equation(right_side)
                if left_expr is None or right_expr is None:
                    return ""  # Incomplete equation
                inequality = left_expr >= right_expr
                relation_type = '>='
            elif '<' in equation_str:
                left_side, right_side = equation_str.split('<', 1)
                left_expr = parse_equation(left_side)
                right_expr = parse_equation(right_side)
                if left_expr is None or right_expr is None:
                    return ""  # Incomplete equation
                inequality = left_expr < right_expr
                relation_type = '<'
            elif '>' in equation_str:
                left_side, right_side = equation_str.split('>', 1)
                left_expr = parse_equation(left_side)
                right_expr = parse_equation(right_side)
                if left_expr is None or right_expr is None:
                    return ""  # Incomplete equation
                inequality = left_expr > right_expr
                relation_type = '>'
            elif '=' in equation_str:
                left_side, right_side = equation_str.split('=', 1)
                left_expr = parse_equation(left_side)
                right_expr = parse_equation(right_side)
                if left_expr is None or right_expr is None:
                    return ""  # Incomplete equation
                inequality = None
                relation_type = '='
            
            # Move everything to the left side
            if relation_type == '=':
                equation = left_expr - right_expr
            else:
                # For inequalities, we need to keep the relation
                equation = left_expr - right_expr
            
            # Solve for x if x is in the equation
            if 'x' in str(equation):
                x = symbols('x')
                
                if relation_type == '=':
                    try:
                        solution = sp.solve(equation, x)
                        if solution:
                            # Format the solution nicely
                            if len(solution) == 1:
                                sol_value = solution[0]
                                # Check if it's a fraction and format accordingly
                                if isinstance(sol_value, sp.Rational) and not sol_value.is_integer:
                                    return f"x = {sol_value.p}/{sol_value.q}"
                                else:
                                    return f"x = {sol_value}"
                            else:
                                return f"x = {solution}"
                        else:
                            return "No solution found"
                    except Exception:
                        return ""  # Cannot solve yet
                else:
                    # Solve inequality
                    try:
                        solution = sp.solve_univariate_inequality(inequality, x)
                        return f"Solution: {solution}"
                    except Exception:
                        return ""  # Cannot solve yet
            else:
                # If it's an equation without x, check if it's true
                if relation_type == '=':
                    try:
                        if sp.simplify(equation) == 0:
                            return "Equation is true"
                        else:
                            return "Equation is false"
                    except Exception:
                        return ""  # Cannot evaluate yet
                else:
                    # For inequalities without x, evaluate if true or false
                    try:
                        result = sp.sympify(inequality)
                        if result is S.true:
                            return "Inequality is true"
                        elif result is S.false:
                            return "Inequality is false"
                        else:
                            return f"Result: {result}"
                    except Exception:
                        return ""  # Cannot evaluate yet
        else:
            # It's an expression, just evaluate it
            expr = parse_equation(equation_str)
            if expr is None:
                return ""  # Incomplete expression
            
            try:
                result = sp.N(expr)  # Numerical evaluation
                
                # Check if result is close to an integer
                if isinstance(result, sp.Float) and abs(result - round(result)) < 1e-10:
                    result = int(round(result))
                
                # Check if it's a fraction and format accordingly
                if isinstance(result, sp.Rational) and not result.is_integer:
                    return f"{result.p}/{result.q}"
                
                return str(result)
            except Exception:
                return ""  # Cannot evaluate yet
    except Exception:
        return ""  # Return empty string instead of error message

def main():
    print("PhotoMath Equation Solver")
    print("Enter 'exit' to quit")
    
    while True:
        equation_str = input("\nEnter a math equation or inequality: ")
        
        if equation_str.lower() == 'exit':
            break
            
        result = solve_equation(equation_str)
        if result:  # Only print if there's a result
            print(f"Result: {result}")

if __name__ == "__main__":
    main()