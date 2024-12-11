"""
author: 
Description: 
Fixed: 
Usage: 
"""

from fastapi import APIRouter
import hosts

router = APIRouter()


# 긴급예약에서 예약하기 눌렀을시 예약DB에 저장
@router.get('/insert_reservation')
async def insert_reservation(user_id: str, clinic_id: str, time: str, symptoms: str, pet_id: str):
    conn = hosts.connect()
    curs = conn.cursor()

    sql = "insert into reservation(user_id, clinic_id, time, symptoms, pet_id) values (%s, %s, %s, %s, %s)"
    curs.execute(sql, (user_id, clinic_id, time, symptoms, pet_id))
    conn.commit()
    conn.close()

    return {'results': 'OK'}

# 예약내역 보여주는 리스트
@router.get('/select_reservation')
async def select_reservation(user_id: str):
    conn = hosts.connect()
    curs = conn.cursor()

    sql = 'select clinic.id, clinic.name, clinic.latitude, clinic.longitude, reservation.time, clinic.address from reservation , clinic where reservation.clinic_id = clinic.id and user_id = %s'
    curs.execute(sql, (user_id))
    rows= curs.fetchall()
    conn.commit()
    conn.close()

    return {'results': rows}

# 병원에서 보는 예약 현황 이종남
@router.get('/select_reservation_clinic')
async def select_reservation(clinic_id: str, time: str):
    conn = hosts.connect()
    curs = conn.cursor()

    sql = '''
    select user.name, res.species_type, res.species_category, res.features, res.symptoms, res.time
    from user,
        (select reservation.user_id, pet.species_type, pet.species_category, pet.features, reservation.symptoms, reservation.time
        from reservation inner join pet
        on reservation.pet_id = pet.id and clinic_id = %s) as res
    where res.user_id = user.id and time like %s order by time asc'''
    time1 =f'{time}%'
    curs.execute(sql, (clinic_id, time1))
    rows= curs.fetchall()
    print(rows)
    conn.commit()
    conn.close()

    return {'results': rows}