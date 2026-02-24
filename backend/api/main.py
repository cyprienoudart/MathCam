from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import sys
import os

# Add project root to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from solver import MathSolver, MathSolution

app = FastAPI(
    title="MathCam API",
    description="API for solving math problems using a local LLM",
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Replace with allowed domains in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Instantiate solver once at startup (reused across requests)
solver = MathSolver()


@app.get("/")
async def root():
    return {"message": "Welcome to MathCam API"}


@app.get("/health")
async def health():
    """Check if Ollama is running and the model is available."""
    healthy = solver.is_healthy()
    return {
        "status": "ok" if healthy else "error",
        "model": solver.config.model,
        "ollama_host": solver.config.ollama_host,
        "model_available": healthy,
    }


@app.post("/solve")
async def solve_math_problem(image: UploadFile = File(...)):
    """Solve a math problem from an image.

    1. OCR extracts the equation from the image
    2. LLM solves it with step-by-step reasoning
    """
    try:
        # Import OCR here to avoid import errors if OCR module isn't set up yet
        from ml_models.ocr import image_processor

        equation = await image_processor.extract_equation(image)

        solution = solver.solve(equation)

        return {
            "equation": solution.problem,
            "steps": solution.steps,
            "answer": solution.answer,
        }
    except ConnectionError as e:
        return JSONResponse(
            status_code=503,
            content={"error": str(e), "hint": "Is Ollama running? Start with: ollama serve"},
        )
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"error": str(e)},
        )


@app.post("/solve/text")
async def solve_text_equation(equation: str = Form(...)):
    """Solve a math problem from text input.

    Accepts any math problem as a string — equations, inequalities,
    word problems, calculus, etc.
    """
    try:
        solution = solver.solve(equation)

        return {
            "equation": solution.problem,
            "steps": solution.steps,
            "answer": solution.answer,
        }
    except ConnectionError as e:
        return JSONResponse(
            status_code=503,
            content={"error": str(e), "hint": "Is Ollama running? Start with: ollama serve"},
        )
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"error": str(e)},
        )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)