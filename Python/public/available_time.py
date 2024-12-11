"""
author: 
Description: 
Fixed: 
Usage: 
"""

from fastapi import APIRouter, HTTPException, File, UploadFile
from fastapi.responses import FileResponse
import pymysql
import os
import hosts
router = APIRouter()

UPLOAD_FOLDER = 'uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

# MySQL 연결 함수
def connect():
    conn = pymysql.connect(
        host=hosts.vet_academy,
        user='root',
        password='qwer1234',
        charset='utf8',
        db='veterinarian'
    )
    return conn

# 예약 가능한 병원id, 이름, password, 경도, 위도, 주소, 이미지, 예약 시간 (예약된 리스트 빼고 나타냄)
@router.get('/available_clinic')
async def get_available_clinic(time:str):
    conn = connect()
    curs = conn.cursor()

    sql = """
    select 
        c.id, c.name, c.latitude, c.longitude, c.address, c.image, ava.time
    from 
        clinic c left outer join
    (select  a.clinic_id ,a.time 
    from available_time a left outer join reservation r on (a.time = r.time  and a.clinic_id = r.clinic_id) 
    where r.time is null and a.time = %s) as ava 
    on 
        (c.id = ava.clinic_id)
    where 
        ava.time is not null
    """
    curs.execute(sql,(time))
    rows = curs.fetchall()
    conn.close()

    if not rows:
        raise HTTPException(status_code=404, detail="예약가능한 병원이 없습니다.")
    
    return {'results': rows}

@router.get("/view/{file_name}")
async def get_file(file_name: str):
    file_path = os.path.join(UPLOAD_FOLDER, file_name)
    if os.path.exists(file_path):
        return FileResponse(path=file_path, filename=file_name)
    return {'result' : 'Error'}

# 신정섭
# clinic_info, location에서 예약 버튼 활성화 관리
@router.get("/can_reservation")
async def can_reservation(time:str=None, clinic_id:str=None):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = '''
            select 
                c.name, c.latitude, c.longitude, c.address, c.image, ava.time, c.id
            from 
                clinic c left outer join
            (select  a.clinic_id ,a.time 
            from available_time a left outer join reservation r on (a.time = r.time  and a.clinic_id = r.clinic_id) 
            where r.time is null and a.time = %s) as ava 
            on 
                (c.id = ava.clinic_id)
            where 
                ava.time is not null and c.id = %s
            '''
        curs.execute(sql,(time,clinic_id))
        rows = curs.fetchone()
        conn.close()
        print(rows)
        return {'result' : rows}
    except Exception as e:
        conn.close()
        print(e)
        return {'result' : e}