"""
author: 정섭
Description:  mypage에서 사용되는 user eidt, query 
Fixed: 
Usage: 
"""


from fastapi import APIRouter, File, UploadFile
from fastapi.responses import FileResponse
import pymysql
import os
import shutil
import hosts, router
mypage_router = APIRouter()

# uploads = 폴더이름
UPLOAD_FOLDER = 'uploads' 

#uploads 폴더가 없으면 새로 만들기
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

#192.168.50.91
def connect():
    conn = pymysql.connect(
        host=hosts.vet_academy,
        user='root',
        password='qwer1234',
        charset='utf8',
        db='veterinarian'
    )
    return conn

# 마이페이지 쿼리
@mypage_router.get('/select_mypage')
def select_mypage(id:str):
    conn = router.connect()
    curs = conn.cursor()
    sql = 'select * from user where id=%s'
    curs.execute(sql,(id))
    rows = curs.fetchone()
    conn.close()
    print(rows)
    return {'result' : rows}


# 유저 이름 수정
@mypage_router.get('/name_update')
def update_mypage (name:str=None,id:str=None,):
    conn = router.connect()
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
async def updateAll(name:str=None, image:str=None, id:str=None):
    conn = router.connect()
    curs = conn.cursor()
    
    try:
        sql = "update user set name=%s,image =%s where id=%s"
        curs.execute(sql,(name,image,id))
        conn.commit()
        conn.close()
        return {'result': "ok"}
    except Exception as e:
        conn.close()
        print("error:",e)
        return {'result' : 'error'}
    

# user 이미지 보기
@mypage_router.get('/view/{file_name}')
async def get_userimage(file_name : str):
    file_path = os.path.join(UPLOAD_FOLDER, file_name)
    if os.path.exists(file_path):
        return FileResponse(path=file_path, filename=file_name)
    return {'result' : 'error'}



# 유저 이미지 업로드
@mypage_router.post("/upload_userimage")
async def upload_file(file : UploadFile = File(...)):
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file.filename)
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        return{'result' : 'ok'}

    except Exception as e:
        print("Error:", e)
        return({"reslut" : "error"})


# 유저 이미지 삭제
@mypage_router.delete("/deleteFile/{file_name}")
async def delete_file(file_name : str):
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file_name)
        if os.path.exists(file_path):
            os.remove(file_path)
        return {"result" : "ok"}
    except Exception as e:
        print("Error:", e)
        return {"result" : "error"}

