"""
author: 
Description: 
Fixed: 
Usage: 
"""

from fastapi import FastAPI
from clinic import router as clinic_router
from profile import mypage_router as mypage_router


app = FastAPI()
app.include_router(clinic_router, prefix="/clinic", tags=["clinic"])

app.include_router(mypage_router,prefix='/mypage', tags=["mypage"])



if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host = "127.0.0.1", port = 8000)