"""
author: 
Description: 
Fixed: 
Usage: 
"""

from fastapi import APIRouter, HTTPException
import pymysql

router = APIRouter()

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
            sql = "SELECT * FROM pets WHERE user_id = %s"
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
@router.post("/pets")
async def add_pet(user_id: str, species_type: str, species_category: str, name: str, birthday: str, features: str, gender: str, image: str = None):
    conn = connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                INSERT INTO pets (id, user_id, species_type, species_category, name, birthday, features, gender, image)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (
                user_id, species_type, species_category, name, 
                birthday, features, gender, image
            ))
            conn.commit()
            return {"message": "Pet added successfully!"}
    finally:
        conn.close()

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