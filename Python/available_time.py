"""
author: 
Description: 
Fixed: 
Usage: 
"""

from fastapi import FastAPI, HTTPException
import pymysql

app = FastAPI()

# MySQL 연결 함수
def connect():
    conn = pymysql.connect(
        host='192.168.50.91',
        user='root',
        password='qwer1234',
        charset='utf8',
        db='veterinarian'
    )
    return conn


@app.get('/available_clinic')
async def get_available_clinic():
    conn = connect()
    curs = conn.cursor()

    sql = """
    select  a.clinic_id ,a.time 
    from available_time a left outer join reservation r on (a.time = r.time  and a.clinic_id = r.clinic_id) 
    where r.time is null;
    """
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()

    if not rows:
        raise HTTPException(status_code=404, detail="예약가능한 병원이 없습니다.")
    
    return {'results': rows}



if __name__ == "__main":
    import uvicorn
    uvicorn.run(app, host='127.0.0.1', port=8000)