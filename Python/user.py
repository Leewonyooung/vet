"""
author: changbin an
Description: db for the user account
Fixed: 07/Oct/2024
Usage: store user acoount information
"""

from fastapi import APIRouter, HTTPException
import pymysql

router = APIRouter()

def connect():
    conn = pymysql.connect(
        host='192.168.50.91',
        user='root',
        passwd='qwer1234',
        db='veterinarian',
        charset='utf8'
    )
    return conn

@router.get("/select")
async def select(id: str=None):
    conn = connect()
    curs = conn.cursor()

    sql = "select id, password, image, name from user where id=%s"
    curs.execute(sql, (id,))
    rows = curs.fetchall()
    conn.close()

    result = [{'id' : row[0], 'password' : row[1],'image' : row[2],'name' : row[3]} for row in rows]
    return {'results' : result}

# @app.get("/select")
# async def select():
#     conn = connect()
#     curs = conn.cursor()

#     sql = "select id, password, image, name from user"
#     curs.execute(sql)
#     rows = curs.fetchall()
#     conn.close()

#     result = [{'id' : row[0], 'password' : row[1],'image' : row[2],'name' : row[3]} for row in rows]
#     return {'results' : result}

@router.get("/insert")
async def insert(id: str=None, password: str=None, image: str=None, name: str=None):
    conn = connect()
    curs = conn.cursor()

    try:
        sql ="insert into user(id, password, image, name) values (%s,%s,%s,%s)"
        curs.execute(sql, (id, password, image, name))
        conn.commit()
        conn.close()
        return {'results': 'OK'}

    except Exception as e:
        conn.close()
        print("Error :", e)
        return {'result': 'Error'}
