"""
author: 
Description: 
Fixed: 
Usage: 
"""

from fastapi import APIRouter
import pymysql
import hosts

router = APIRouter()


def connect():
    conn = pymysql.connect(
        host=hosts.vet_academy,
        user='root',
        password='qwer1234',
        db='veterinarian',
        charset='utf8'
    )
    return conn

# 긴급예약에서 예약하기 눌렀을시 예약DB에 저장
@router.get('/insert_reservation')
async def insert_reservation(user_id: str, clinic_id: str, time: str, symptoms: str):
    conn = connect()
    curs = conn.cursor()

    sql = "insert into reservation(user_id, clinic_id, time, symptoms) values (%s, %s, %s, %s)"
    curs.execute(sql, (user_id, clinic_id, time, symptoms))
    conn.commit()
    conn.close()

    return {'results': 'OK'}

# 예약내역 보여주는 리스트
@router.get('/select_reservation')
async def select_reservation(user_id: str):
    conn = connect()
    curs = conn.cursor()

    sql = 'select clinic.id, clinic.name, clinic.latitude, clinic.longitude, reservation.time, clinic.address from reservation , clinic where reservation.clinic_id = clinic.id and user_id = %s'
    curs.execute(sql, (user_id))
    rows= curs.fetchall()
    conn.commit()
    conn.close()

    return {'results': rows}