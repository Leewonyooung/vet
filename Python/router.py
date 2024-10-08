"""
author: 
Description: 
Fixed: 
Usage: 
"""

from fastapi import FastAPI
from clinic import router as clinic_router
from favorite import router as favorite_router
from user import router as user_router

app = FastAPI()
app.include_router(clinic_router, prefix="/clinic", tags=["clinic"])
app.include_router(favorite_router, prefix="/favorite", tags=["favorite"])
app.include_router(user_router, prefix="/user", tags=["user"])

app.include_router(mypage_router,prefix='/mypage', tags=["mypage"])



if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host = "127.0.0.1", port = 8000)