"""
author: 
Description: 
Fixed: 
Usage: 
"""


from fastapi import APIRouter, File, UploadFile
from fastapi.responses import FileResponse
import pymysql
import os
import shutil

mypage_router = APIRouter()

# uploads = 폴더이름
UPLOAD_FOLDER = 'uploads' 

#uploads 폴더가 없으면 새로 만들기
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

#192.168.50.91
def connect():
    conn = pymysql.connect(
        host='192.168.50.91',
        user='root',
        password='qwer1234',
        charset='utf8',
        db='veterinarian'
    )
    return conn

# 마이페이지 쿼리
@mypage_router.get('/select_mypage')
def select_mypage(id:str):
    conn = connect()
    curs = conn.cursor()
    sql = 'select * from user where id=%s'
    curs.execute(sql,(id))
    rows = curs.fetchall()
    conn.close()
    print(rows)
    return {'result' : rows}


# 유저 이름 수정
@mypage_router.get('/name_update')
def update_mypage (name:str=None,id:str=None,):
    conn = connect()
    curs = conn.cursor()
    
    try:
        sql = "update user set name=%s where id=%s"
        curs.execute(sql,(name,id))
        conn.commit()
        conn.close()
        return {'result': "ok"}
    except Exception as e:
        conn.close()
        print("error:",e)
        return {'result' : 'error'}
    
# 유저 이미지, 이름 모두 수정
@mypage_router.get('/all_update')
async def updateAll(seq = str,name:str=None, filename:str=None):
    conn = connect()
    curs = conn.cursor()
    
    try:
        sql = "update user set name=%s,filename =%s where id=%s"
        curs.execute(sql,(name,filename,id))
        conn.commit()
        conn.close()
        return {'result': "ok"}
    except Exception as e:
        conn.close()
        print("error:",e)
        return {'result' : 'error'}


# 유저 프로필 사진 파일 지우기
@mypage_router.delete('/delete_userimage/{file_name}')
async def delete_userimage(file_name:str):
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file_name)
        if os.path.exists(file_path):
            os.remove(file_path)
        return {'result': 'ok'}
    except Exception as e:
        print("Error:",e)
        return {'result':'error'}


# user profile 보기
@mypage_router.get('/userimage/{file_name}')
async def get_userimage(file_name : str):
    file_path = os.path.join(UPLOAD_FOLDER, file_name)
    if os.path.exists(file_path):
        return FileResponse(path=file_path, filename=file_name)
    return {'result' : 'error'}



