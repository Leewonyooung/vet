"""
author: 이원영
Description: 병원 테이블 API 핸들러
Fixed: 2024/10/7
Usage: 
"""

from fastapi import APIRouter, File, UploadFile
from fastapi.responses import FileResponse
import pymysql
import os
import shutil


router = APIRouter()

UPLOAD_FOLDER = 'uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)



def connect():
    conn = pymysql.connect(
        host = "192.168.50.91", 
        user = "root",
        password = "qwer1234",
        db = "veterinarian",
        charset= 'utf8'
    )
    return conn


@router.get("/")
async def select():
    conn = connect()
    curs = conn.cursor()
    try:
        sql = 'select * from clinic'
        curs.execute(sql)
        rows= curs.fetchall()
        conn.close()
        result = [{'id' : row[0], 'name' : row[1], 'password' : row[2], 'latitude' : row[3], 'longitude' : row[4], 'start_time': row[5], 'end_time': row[6], 'introduction': row[7], 'address': row[8], 'phone': row[9], 'image': row[10]} for row in rows]
        print(f"병원 검색 \n{result}")
        return{'results': result}
    except Exception as e:
        conn.close()
        print("Error:", e)
        return{"results" : "Error"}


@router.get("/chatimage")
async def select(id : str):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = 'select image from clinic where id = %s'
        curs.execute(sql,(id))
        rows = curs.fetchall()
        rows = rows[0]
        conn.close()
        return{'results': rows}
    except Exception as e:
        conn.close()
        print("Error:", e)
        return{"results" : "Error"}


@router.get("/delete")
async def delete(id : str = None):
    conn = connect()
    curs = conn.cursor()

    try:
        sql = "delete from image where id=%s"
        curs.execute(sql, (id))
        conn.commit()
        conn.close()
        return {"result" : "OK"}
    
    except Exception as e:
        conn.close()
        print("Error :",e)
        return {"result" : "Error"}
    

@router.post("/upload")
async def upload_file(file : UploadFile = File(...)):
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file.filename)
        with open(file_path, "wb") as buffer: ## "wb" : write binarry
            shutil.copyfileobj(file.file, buffer)
        return{'result' : 'OK'}

    except Exception as e:
        print("Error:", e)
        return({"reslut" : "Error"})


@router.get("/view/{file_name}")
async def get_file(file_name: str):
    file_path = os.path.join(UPLOAD_FOLDER, file_name)
    if os.path.exists(file_path):
        return FileResponse(path=file_path, filename=file_name)
    return {'result' : 'Error'}


@router.delete("/deleteFile/{file_name}")
async def delete_file(file_name : str):
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file_name)
        if os.path.exists(file_path):
            os.remove(file_path)
        return {"result" : "OK"}
    except Exception as e:
        print("Error:", e)
        return {"result" : "Error"}
    

    # 병원 전체 목록
@router.get('/select_clinic')
async def all_clinic():
    conn = connect()
    curs = conn.cursor()
    sql = "select * from clinic"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    return {'results' : rows} # 결과 값 = list(key값 x)

"""
author: 이원영
Fixed: 2024/10/7
Usage: 채팅창 보여줄때 id > name
"""
@router.get('/select_clinic_name')
async def all_clinic(name:str):
    # name= ['adfki125', 'adkljzci9786']
    try:
        conn = connect()
        curs = conn.cursor()
        sql = "select name from clinic where id = %s"
        curs.execute(sql,(name))
        rows = curs.fetchall()
        conn.close()
        return {'results' : rows[0]}
    except Exception as e:
        conn.close()
        print("Error :",e)
        return {"result" : "Error"}

# 병원 검색 활용
@router.get('/select_search')
async def search_clinic(name:str=None):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'select * from clinic where id = %s'
        curs.execute(sql,(name))
        rows = curs.fetchall()
        conn.close()
        return{'results' : rows}
    except Exception as e:
        conn.close()
        print("Error : ", e)
        return{'result' " 'error"}

# 상세화면 정보 불러오기
@router.get('/detail_clinic')
async def detail_clinic(id: str):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = "select * from clinic where id=%s"
        curs.execute(sql,(id))
        rows = curs.fetchall()
        conn.close()
        return {'results' : rows} # 결과 값 = list(key값 x)
    except Exception as e:
        conn.close()
        print("Error:", e)
        return {'Error' : 'error'}


   

    # 병원 전체 목록
@router.get('/select_clinic')
async def all_clinic():
    try:
        conn = connect()
        curs = conn.cursor()
        sql = "select * from clinic"
        curs.execute(sql)
        rows = curs.fetchall()
        conn.close()
        return {'results' : rows} # 결과 값 = list(key값 x)
    except Exception as e:
        conn.close()
        print("Error:", e)
        return {'Error' : 'error'}

# 병원 검색 활용
@router.get('/select_search')
async def search_clinic(name:str=None):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'select * from clinic where id = %s'
        curs.execute(sql,(name))
        rows = curs.fetchall()
        conn.close()
        return{'results' : rows}
    except Exception as e:
        conn.close()
        print("Error:", e)
        return {'Error' : 'error'}

# 상세화면 정보 불러오기
@router.get('/detail_clinic')
async def detail_clinic(id: str):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = "select * from clinic where id=%s"
        curs.execute(sql,(id))
        rows = curs.fetchall()
        conn.close()
        print(rows)
        return {'results' : rows} # 결과 값 = list(key값 x)
    except Exception as e:
        conn.close()
        print("Error:", e)
        return {'Error' : 'error'}

# insert clinic (안창빈)

@router.get("/insert")
async def insert(
    id: str=None, 
    name: str=None, 
    password: str=None, 
    latitude: float=None, 
    longitude: float=None, 
    start_time: str=None, 
    end_time: str=None, 
    introduction: str=None, 
    address: str=None, 
    phone: str=None, 
    image: str=None,
):
    conn = connect()
    curs = conn.cursor()

    try:
        sql ="insert into clinic(id, name, password, latitude, longitude, start_time, end_time, introduction, address, phone, image) values (%s,%s,%s,%s,%s)"
        curs.execute(sql, (id, name, password, latitude, longitude, start_time, end_time, introduction, address, phone, image))
        conn.commit()
        conn.close()
        return {'results': 'OK'}

    except Exception as e:
        conn.close()
        print("Error :", e)
        return {'result': 'Error'}    
    
# update clinic (안창빈)

@router.get("/update")
async def update(
    id: str=None, 
    name: str=None, 
    password: str=None, 
    latitude: float=None, 
    longitude: float=None, 
    start_time: str=None, 
    end_time: str=None, 
    introduction: str=None, 
    address: str=None, 
    phone: str=None, 
    image: str=None,
):
    conn = connect()
    curs = conn.cursor()

    try:
        sql = """
        UPDATE clinic
        SET name = %s,
        password = %s,
        latitude = %s,
        longitude = %s,
        start_time = %s,
        end_time = %s,
        introduction = %s,
        address = %s,
        phone = %s,
        image = %s
        WHERE id = %s
        """
        curs.execute(sql, (name, password, latitude, longitude, start_time, end_time, introduction, address, phone, image, id))
        conn.commit()
        conn.close
        return {'results': 'OK'} 
    


    except Exception as e:
        conn.close()
        print("Error :", e)
        return {'result': 'Error'}    

