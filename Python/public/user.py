"""
author: changbin an
Description: db for the user account
Fixed: 07/Oct/2024
Usage: store user(include clinic) acoount information
"""

from fastapi import APIRouter 
import pymysql
import hosts

router = APIRouter()

def connect():
    conn = pymysql.connect(
        host=hosts.vet_academy,
        user='root',
        passwd='qwer1234',
        db='veterinarian',
        charset='utf8'
    )
    return conn

    ## Check User account from db  (안창빈)

@router.get("/selectuser")
async def select(id: str=None):
    conn = connect()
    curs = conn.cursor()

    sql = "select id, password, image, name, phone from user where id=%s"
    curs.execute(sql, (id,))
    rows = curs.fetchall()
    conn.close()

    result = [{'id' : row[0], 'password' : row[1],'image' : row[2],'name' : row[3], 'phone' : row[3]} for row in rows]
    return {'results' : result}


    ## add google acount to sql db if it is an new user  (안창빈)

@router.get("/insertuser")
async def insert(id: str=None, password: str=None, image: str=None, name: str=None, phone: str=None):
    conn = connect()
    curs = conn.cursor()

    try:
        sql ="insert into user(id, password, image, name, phone) values (%s,%s,%s,%s,%s)"
        curs.execute(sql, (id, password, image, name, phone))
        conn.commit()
        conn.close()
        return {'results': 'OK'}

    except Exception as e:
        conn.close()
        print("Error :", e)
        return {'result': 'Error'}
    

## Check clinic account from db  (안창빈)

@router.get("/selectclinic")
async def select(id: str=None, password: str=None):
    conn = connect()
    curs = conn.cursor()

    sql = "select id, password from clinic where id=%s and password=%s"
    curs.execute(sql, (id, password,))
    rows = curs.fetchall()
    conn.close()

    result = [{'id' : row[0], 'password' : row[1]} for row in rows]
    return {'results' : result}


"""
author: 이원영
Fixed: 2024/10/7
Usage: 채팅창 보여줄때 id > name
"""
@router.get('/get_user_name')
async def get_user_name(id:str):
    # name= ['adfki125', 'adkljzci9786']
    try:
        conn = connect()
        curs = conn.cursor()
        sql = "select name from user where id = %s"
        curs.execute(sql,(id))
        rows = curs.fetchall()
        conn.close()
        return {'results' : rows[0]}
    except Exception as e:
        conn.close()
        print("Error :",e)
        return {"result" : "Error"}