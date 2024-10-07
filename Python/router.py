"""
author: 
Description: 
Fixed: 
Usage: 
"""

from fastapi import FastAPI
from clinic import router as clinic_router



app = FastAPI()
app.include_router(clinic_router, prefix="/clinic", tags=["clinic"])



if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host = "127.0.0.1", port = 8000)