"""
author: 
Description: 
Fixed: 
Usage: 
"""

from fastapi import APIRouter, HTTPException 
import pymysql

router = APIRouter()

# MySQL 연결 함수
def connection():
    conn = pymysql.connect(
        host='192.168.50.91',
        user='root',
        password='qwer1234',
        charset='utf8',
        db='veterinarian'
    )
    return conn

# 사용자의 즐겨찾기 목록 불러오기
@router.get('/favorite_clinics')
async def get_favorite_clinics(user_id: str):
    conn = connection()
    curs = conn.cursor()

    sql = "SELECT * FROM favorite WHERE user_id = %s"
    curs.execute(sql, (user_id,))
    rows = curs.fetchall()
    conn.close()

    if not rows:
        raise HTTPException(status_code=404, detail="즐겨찾기 병원이 없습니다.")
    
    return {'results': rows}

# 즐겨찾기 추가
@router.post('/add_favorite')
async def add_favorite(user_id: str, clinic_id: str):
    conn = connection()
    curs = conn.cursor()

    # 중복 확인
    sql_check = "SELECT * FROM favorite WHERE user_id = %s AND clinic_id = %s"
    curs.execute(sql_check, (user_id, clinic_id))
    result = curs.fetchone()

    if result:
        raise HTTPException(status_code=400, detail="이미 즐겨찾기 목록에 있습니다.")

    # 즐겨찾기 추가 (clinic 테이블에서 데이터를 가져와 favorite 테이블에 삽입)
    sql = """
        INSERT INTO favorite (user_id, clinic_id, name, password, latitude, longitude, start_time, end_time, introduction, address, phone)
        SELECT %s, id, name, password, latitude, longitude, start_time, end_time, introduction, address, phone
        FROM clinic WHERE id = %s
    """
    curs.execute(sql, (user_id, clinic_id))
    conn.commit()
    conn.close()

    return {"message": "즐겨찾기 병원이 추가되었습니다."}

# 즐겨찾기 삭제
@router.delete('/delete_favorite')
async def delete_favorite(user_id: str, clinic_id: str):
    conn = connection()
    curs = conn.cursor()

    # 즐겨찾기 삭제
    sql = "DELETE FROM favorite WHERE user_id = %s AND clinic_id = %s"
    result = curs.execute(sql, (user_id, clinic_id))
    conn.commit()
    conn.close()

    if result == 0:
        raise HTTPException(status_code=404, detail="해당 병원이 즐겨찾기에 없습니다.")

    return {"message": "즐겨찾기 병원이 삭제되었습니다."}

