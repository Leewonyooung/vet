"""
author: Aeong
Description: pet
Fixed: 2024.10.11
Usage: 
"""

from fastapi import APIRouter, HTTPException, File, UploadFile, Form
from fastapi.responses import FileResponse
import os
import pymysql
import shutil

router = APIRouter()

UPLOAD_DIRECTORY = "uploads/"  # 이미지 저장 경로

# 이미지 저장 디렉터리 확인 및 생성
if not os.path.exists(UPLOAD_DIRECTORY):
    os.makedirs(UPLOAD_DIRECTORY)

def connection():
    conn = pymysql.connect(
        host='192.168.50.91',
        user='root',
        password='qwer1234',
        charset='utf8',
        db='veterinarian'
    )
    return conn

# 반려동물 조회 API (GET)
@router.get("/pets")
async def get_pets(user_id: str):
    conn = connection()
    try:
        with conn.cursor() as cursor:
            sql = "SELECT * FROM pet WHERE user_id = %s"
            cursor.execute(sql, (user_id,))
            pets = cursor.fetchall()

            if not pets:
                raise HTTPException(status_code=404, detail="No pets found for this user.")

            # 데이터 형식으로 변환하여 반환
            return [
                {
                    "id": pet[0],
                    "user_id": pet[1],
                    "species_type": pet[2],
                    "species_category": pet[3],
                    "name": pet[4],
                    "birthday": pet[5],
                    "features": pet[6],
                    "gender": pet[7],
                    "image": pet[8],
                }
                for pet in pets
            ]
    finally:
        conn.close()

# 반려동물 등록 API (POST)
@router.post("/insert")
async def add_pet(
    id: str = Form(...),
    user_id: str = Form(...),
    species_type: str = Form(...),
    species_category: str = Form(...),
    name: str = Form(...),
    birthday: str = Form(...),
    features: str = Form(...),
    gender: str = Form(...),
    image: UploadFile = File(...)
):
    # 이미지 파일 이름만 추출
    image_filename = image.filename
    image_path = os.path.join(UPLOAD_DIRECTORY, image_filename)  # 전체 경로

    # 이미지 저장
    with open(image_path, "wb") as buffer:
        shutil.copyfileobj(image.file, buffer)

    # 데이터베이스에는 파일 이름만 저장
    conn = connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                INSERT INTO pet (id, user_id, species_type, species_category, name, birthday, features, gender, image)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (
                id, user_id, species_type, species_category, name, 
                birthday, features, gender, image_filename  # 경로 대신 파일 이름만 저장
            ))
            conn.commit()  # 데이터베이스에 변경사항 저장
            return {"message": "Pet added successfully!"}
    finally:
        conn.close()

# 이미지 제공 API
@router.get("/uploads/{file_name}")
async def get_file(file_name: str):
    file_path = os.path.join(UPLOAD_DIRECTORY, file_name)
    if os.path.exists(file_path):
        return FileResponse(path=file_path, filename=file_name)
    return {"error": "File not found"}

# 반려동물 삭제 API (DELETE)
@router.delete("/pets/{pet_id}")
async def delete_pet(pet_id: str):
    conn = connection()
    try:
        with conn.cursor() as cursor:
            sql = "DELETE FROM pets WHERE id = %s"
            result = cursor.execute(sql, (pet_id,))
            conn.commit()

            if result == 0:
                raise HTTPException(status_code=404, detail="Pet not found.")

            return {"message": "Pet deleted successfully!"}
    finally:
        conn.close()