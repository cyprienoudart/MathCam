from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import sys
import os

# Ajouter les chemins du projet au PATH
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from ml_models.ocr import image_processor
from ml_models.math_solver.math_solver import solve_equation

app = FastAPI(title="MathCam API", description="API for solving math problems from images")

# Configuration CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # A remplacer par les domaines autorisés en production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Welcome to MathCam API"}

@app.post("/solve")
async def solve_math_problem(image: UploadFile = File(...)):
    try:
        # Processus en 2 étapes:
        # 1. OCR pour extraire l'équation de l'image
        equation = await image_processor.extract_equation(image)
        
        # 2. Résoudre l'équation
        solution = solve_equation(equation)
        
        return {
            "equation": equation,
            "solution": solution
        }
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"error": str(e)}
        )

@app.post("/solve/text")
async def solve_text_equation(equation: str = Form(...)):
    try:
        solution = solve_equation(equation)
        return {
            "equation": equation,
            "solution": solution
        }
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"error": str(e)}
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 