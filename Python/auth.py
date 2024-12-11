"""
author: 이원영
Description: login API with JWT
Fixed: 2024/10/7
Usage: 로그인시 JWT 토큰 인증절차를 통한 보안성 확보
"""
from datetime import datetime, timedelta
from fastapi import APIRouter
from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from typing import Optional
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
import hosts


router = APIRouter()


# Password 암호화
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# OAuth2 설정
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/token")

class RefreshTokenRequest(BaseModel):
    refresh_token: str

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

async def get_user(id: str, password: str):
    user_data = await select(id=id) 
    results = user_data.get("results")
    if results:
        return results[0]  
    return None

async def authenticate_user(id: str, password: str):
    user = await get_user(id=id, password=pwd_context.hash(password))
    if not user or not verify_password(password, user["password"]):  # 딕셔너리 접근
        return False
    return user

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def create_refresh_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


async def select(id: str = None):
    conn = hosts.connect()
    curs = conn.cursor()
    sql = "SELECT * FROM user WHERE id=%s"
    curs.execute(sql, (id))
    rows = curs.fetchall()
    conn.close()
    result = [
        {"id": row[0], "password": row[1], "age": row[2], "sex": row[3], "name": row[4]}
        for row in rows
    ]
    return {"results": result}

# JWT 유효성 검증
def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("id")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        return user_id
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")



@router.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = await authenticate_user(id=form_data.username, password=form_data.password)  # await 추가
    if not user:
        raise HTTPException(
            status_code=401,
            detail="Invalid username or password",
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    # access_token = create_access_token(data={"id": user["id"]})
    access_token = create_access_token(
        data={"id": user["id"], "password":user['password']}, expires_delta=access_token_expires
    )
    refresh_token = create_refresh_token( data={"id": user["id"], "password":user['password']})
    return {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"}

# refreshToken으로 새로운 accessToken 발급
@router.post("/token/refresh")
async def refresh_token(request: RefreshTokenRequest):
    try:
        print(f"Received refresh token: {request.refresh_token}")  # 디버깅 로그 추가
        payload = jwt.decode(request.refresh_token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("id")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid refresh token")
    except JWTError as e:
        print(f"JWT Error: {e}")  # 디버깅 로그 추가
        raise HTTPException(status_code=401, detail="Invalid refresh token")
    
    # 새 accessToken 발급
    new_access_token = create_access_token(data={"id": user_id})
    return {"access_token": new_access_token, "token_type": "bearer"}