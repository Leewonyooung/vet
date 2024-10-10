"""
author: 
Description: 
Fixed: 
Usage: 
"""

from fastapi import FastAPI, File, HTTPException, UploadFile
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

# 긴급예약에서 예약하기 눌렀을시 예약DB에 저장
@app.get('/insert_reservation')
async def insert_reservation(user_id: str, clinic_id: str, time: str):
    conn = connect()
    curs = conn.cursor()

    sql = "insert into reservation(user_id, clinic_id, time) values (%s, %s, %s)"
    curs.execute(sql, (user_id, clinic_id, time))
    rows = curs.fetchall()
    conn.close()

    if not rows:
        raise HTTPException(status_code=404, detail="예약가능한 병원이 없습니다.")
    
    return {'results': rows}

@app.get('/complete_reservation')
async def complete_reservation(user_id: str):
    conn = connect()
    curs = conn.cursor()

    sql = "insert into reservation(user_id, clinic_id, time) values (%s, %s, %s)"
    curs.execute(sql, (user_id))
    rows = curs.fetchall()
    conn.close()

    if not rows:
        raise HTTPException(status_code=404, detail="예약가능한 병원이 없습니다.")
    
    return {'results': rows}


if __name__ == "__main":
    import uvicorn
    uvicorn.run(app, host='127.0.0.1', port=8000)