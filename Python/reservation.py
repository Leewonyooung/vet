"""
author: 
Description: 
Fixed: 
Usage: 
"""

from fastapi import FastAPI, File, UploadFile
from fastapi.responses import FileResponse
import pymysql
import os
import shutil

app = FastAPI()

UPLOAD_FOLDER = 'uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

def connect():
    conn = pymysql.connect(
        host='192.168.50.91',
        user='root',
        password='qwer1234',
        db='veterinarian',
        charset='utf8'
    )
    return conn

if __name__ == "__main":
    import uvicorn
    uvicorn.run(app, host='127.0.0.1', port=8000)