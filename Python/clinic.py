"""
author: 정섭
Description: 
Fixed: 
Usage: 
"""

from fastapi import FastAPI, File, UploadFile
from fastapi.responses import FileResponse
import pymysql
import os #directory 만들기, 이동
import shutil

app = FastAPI()

# uploads = 폴더이름
UPLOAD_FOLDER = 'uploads' 

#uploads 폴더가 없으면 새로 만들기
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

#192.168.50.91
def connection():
    conn = pymysql.connect(
        host='192.168.50.91',
        user='root',
        password='qwer1234',
        charset='utf8',
        db='veterinarian'
    )
    return conn




# 병원 전체 목록
@app.get('/select_clinic')
async def all_clinic():
    conn = connection()
    curs = conn.cursor()

    sql = "select * from clinic"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    return {'results' : rows} # 결과 값 = list(key값 x)


# 병원 검색 활용
@app.get('/select_search')
async def search_clinic(name:str=None):
    conn = connection()
    curs = conn.cursor()

    sql='select * from clinic where name like %s'
    curs.execute(sql,(name))
    rows = curs.fetchall()
    conn.close()
    return{'results' : rows}

# 상세화면 정보 불러오기
@app.get('/detail_clinic')
async def detail_clinic(id: str):
    conn = connection()
    curs = conn.cursor()

    sql = "select * from clinic where id=%s"
    curs.execute(sql,(id))
    rows = curs.fetchall()
    conn.close()
    print(rows)
    return {'results' : rows} # 결과 값 = list(key값 x)




if __name__ == "__main":
    import uvicorn
    uvicorn.run(app, host='127.0.0.1', port=8000)