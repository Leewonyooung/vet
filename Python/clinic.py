"""
author: 이원영
Description: 병원 테이블 API 핸들러
Fixed: 2024/10/7
Usage: 
"""

from fastapi import APIRouter, File, UploadFile
from fastapi.responses import FileResponse
import os
import hosts
from botocore.exceptions import NoCredentialsError
from botocore.exceptions import ClientError
from fastapi.responses import StreamingResponse
import io

router = APIRouter()

UPLOAD_FOLDER = 'uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

@router.get("/delete")
async def delete(id : str = None):
    conn = hosts.connect()
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
async def upload_file_to_s3(file: UploadFile = File(...)):
    try:
        # S3 버킷에 저장할 파일 이름
        s3_key = file.filename

        # 파일 내용을 S3로 업로드
        hosts.s3.upload_fileobj(file.file, hosts.BUCKET_NAME, s3_key)

        # 성공 응답
        return {'result': 'OK', 's3_key': s3_key}

    except NoCredentialsError:
        return {'result': 'Error', 'message': 'AWS credentials not available.'}

    except Exception as e:
        print("Error:", e)
        return {'result': 'Error', 'message': str(e)}


# @router.get("/view/{file_name}")
# async def get_file(file_name: str):
#     file_path = os.path.join(UPLOAD_FOLDER, file_name)
#     if os.path.exists(file_path):
#         return FileResponse(path=file_path, filename=file_name)
#     else:
#         return FileResponse(rrrrpath=file_path, filename='usericon.jpg')

# @router.get("/view/{file_name}")
# async def get_file(file_name: str):
#     try:
#         # S3 버킷 이름 확인
#         print(f"Using bucket: {hosts.BUCKET_NAME}")

#         # S3에서 해당 파일의 URL 생성
#         response = hosts.s3.generate_presigned_url(
#             'get_object',
#             Params={'Bucket': hosts.BUCKET_NAME, 'Key': file_name},
#             ExpiresIn=3600
#         )
#         return RedirectResponse(url=response)  # URL 리디렉션
#     except ClientError as e:
#         print(f"Error fetching file: {file_name}. Error: {e}")
#         return {"result": "Error", "message": "File not found in S3."}
#     except Exception as e:
#         print(f"Unexpected error: {e}")
#         return {"result": "Error", "message": str(e)}



@router.get("/view/{file_name}")
async def get_file(file_name: str):
    try:
        # S3에서 파일 데이터를 가져옵니다.
        file_obj = hosts.s3.get_object(Bucket=hosts.BUCKET_NAME, Key=file_name)
        file_data = file_obj['Body'].read()

        # 파일 데이터를 클라이언트에 반환합니다.
        return StreamingResponse(io.BytesIO(file_data), media_type="image/jpeg")
    except ClientError as e:
        print(f"Error fetching file: {file_name}. Error: {e}")
        return {"result": "Error", "message": "File not found in S3."}
    except Exception as e:
        print(f"Unexpected error: {e}")
        return {"result": "Error", "message": str(e)}



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
    

"""
author: 이원영
Fixed: 2024/10/7
Usage: 채팅창 보여줄때 id > name
"""
@router.get('/select_clinic_name')
async def all_clinic(name:str):
    # name= ['adfki125', 'adkljzci9786']
    conn = hosts.connect()
    try:
        # conn = hosts.connect()
        curs = conn.cursor()
        sql = "select name from clinic where id = %s"
        curs.execute(sql,(name))
        rows = curs.fetchall()
        conn.close()
        return {'results' : rows}
    except Exception as e:
        conn.close()
        print("Error :",e)
        return {"result" : "Error"}



"""
author: 이원영
Fixed: 2024/10/7
Usage: 채팅창 보여줄때 name > id
"""
@router.get('/get_clinic_name')
async def get_user_name(name:str):
    conn = hosts.connect()
    try:
        curs = conn.cursor()
        sql = "select id from clinic where name = %s"
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
async def select_search(word:str=None):
    conn = hosts.connect()
    try:
        curs = conn.cursor()
        sql = 'select * from clinic where name like %s or address like %s'
        keyword = f"%{word}%"
        curs.execute(sql,(keyword, keyword))
        rows = curs.fetchall()
        conn.close()
        return{'results' : rows}
    except Exception as e:
        conn.close()
        print("Error : ", e)
        return{'results' " 'error"}

# 상세화면 정보 불러오기
@router.get('/detail_clinic')
async def detail_clinic(id: str):
    conn = hosts.connect()
    try:
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
    conn = hosts.connect()
    try:
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



# insert new clinic information to DB (안창빈)

@router.get("/insert")
async def insert(
    id: str=None, 
    name: str=None, 
    password: str=None, 
    latitude: str=None, 
    longitude: str=None, 
    starttime: str=None, 
    endtime: str=None, 
    introduction: str=None, 
    address: str=None, 
    phone: str=None, 
    image: str=None,
):
    conn = hosts.connect()
    curs = conn.cursor()

    try:
        sql ="insert into clinic(id, name, password, latitude, longitude, start_time, end_time, introduction, address, phone, image) values (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
        curs.execute(sql, (id, name, password, latitude, longitude, starttime, endtime, introduction, address, phone, image))
        conn.commit()
        conn.close()
        return {'results': 'OK'}

    except Exception as e:
        conn.close()
        print("Error :", e)
        return {'result': 'Error'}    
    
# edit clinic information to DB (안창빈)

@router.get("/update")
async def update(
    id: str=None, 
    name: str=None, 
    password: str=None, 
    latitude: str=None, 
    longitude: str=None, 
    starttime: str=None, 
    endtime: str=None, 
    introduction: str=None, 
    address: str=None, 
    phone: str=None, 
):
    conn = hosts.connect()
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
        phone = %s
        WHERE id = %s
        """
        curs.execute(sql, (name, password, latitude, longitude, starttime, endtime, introduction, address, phone, id))
        conn.commit()
        conn.close
        return {'results': 'OK'} 
    
    except Exception as e:
        conn.close()
        print("Error :", e)
        return {'result': 'Error'}    
    
# edit clinic information to DB (안창빈)

@router.post("/update_all")
async def update(
    id: str=None, 
    name: str=None, 
    password: str=None, 
    latitude: str=None, 
    longitude: str=None, 
    starttime: str=None, 
    endtime: str=None, 
    introduction: str=None, 
    address: str=None, 
    phone: str=None, 
    image: str=None,
):
    conn = hosts.connect()
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
        curs.execute(sql, (name, password, latitude, longitude, starttime, endtime, introduction, address, phone, image, id))
        conn.commit()
        conn.close
        return {'results': 'OK'} 
    
    except Exception as e:
        conn.close()
        print("Error :", e)
        return {'result': 'Error'}   
    


