"""
author: Aeong
Description: species
Fixed: 2024.10.12
Usage: Manage species types and categories
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

# 모든 종류 조회 API (GET)
@router.get("/types")
async def get_species_types():
    conn = connection()
    try:
        with conn.cursor() as cursor:
            sql = "SELECT DISTINCT type FROM species"
            cursor.execute(sql)
            types = cursor.fetchall()

            if not types:
                raise HTTPException(status_code=404, detail="No species types found.")

            return [type[0] for type in types]
    finally:
        conn.close()

# 특정 종류의 세부 종류 조회 API (GET)
@router.get("/categories")
async def get_species_categories(type: str):
    conn = connection()
    try:
        with conn.cursor() as cursor:
            sql = "SELECT category FROM species WHERE type = %s"
            cursor.execute(sql, (type,))
            categories = cursor.fetchall()

            if not categories:
                raise HTTPException(status_code=404, detail="No categories found for this species type.")

            return [category[0] for category in categories]
    finally:
        conn.close()

# 새로운 종류 추가 API (POST)
@router.post("/add")
async def add_species(species_type: str, species_category: str):
    conn = connection()
    try:
        with conn.cursor() as cursor:
            sql = "INSERT INTO species (type, category) VALUES (%s, %s)"
            cursor.execute(sql, (species_type, species_category))
            conn.commit()
            return {"message": "Species added successfully!"}
    except pymysql.IntegrityError:
        raise HTTPException(status_code=400, detail="This species already exists.")
    finally:
        conn.close()

# 종류 삭제 API (DELETE)
@router.delete("/delete")
async def delete_species(species_type: str, species_category: str):
    conn = connection()
    try:
        with conn.cursor() as cursor:
            sql = "DELETE FROM species WHERE type = %s AND category = %s"
            result = cursor.execute(sql, (species_type, species_category))
            conn.commit()

            if result == 0:
                raise HTTPException(status_code=404, detail="Species not found.")

            return {"message": "Species deleted successfully!"}
    finally:
        conn.close()