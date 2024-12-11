"""
author: 정섭
Description:  mypage에서 사용되는 user eidt, query 
Fixed: 
Usage: 
"""



from fastapi import APIRouter, File, UploadFile
from fastapi.responses import FileResponse
import os
import shutil
import hosts
from fastapi.responses import StreamingResponse
import io
from botocore.exceptions import ClientError, NoCredentialsError

mypage_router = APIRouter()

# uploads = 폴더이름
UPLOAD_FOLDER = 'uploads' 

#uploads 폴더가 없으면 새로 만들기
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)



# 마이페이지 쿼리
@mypage_router.get('/select_mypage')
def select_mypage(id:str):
    conn = hosts.connect()
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
    conn = hosts.connect()
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
    conn = hosts.connect()
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


# 유저 이미지 업로드
@mypage_router.post("/upload_userimage")
async def upload_file(file : UploadFile = File(...)):
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


# 유저 이미지 삭제
@mypage_router.delete("/deleteFile/{file_name}")
async def delete_file(file_name : str):
    try:
        # S3에서 파일 삭제
        hosts.s3.delete_object(Bucket=hosts.BUCKET_NAME, Key=file_name)
        return {"result": "OK", "message": f"File {file_name} deleted successfully from bucket {hosts.BUCKET_NAME}"}
    except ClientError as e:
        print(f"Error deleting file: {file_name}. Error: {e}")
        return {"result": "Error", "message": str(e)}
    except Exception as e:
        print(f"Unexpected error: {e}")
        return {"result": "Error", "message": str(e)}
