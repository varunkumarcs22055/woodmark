import os
import pymysql
from dotenv import load_dotenv

load_dotenv()
db_url = os.getenv('DATABASE_URL', '')
print(f"Testing connection to: {db_url.split('@')[-1]}")

try:
    # Manual parse for simple test
    # mysql://woodmark:ecommerce%4012345@68.178.232.132:3306/ecommerce
    user_pass, host_db = db_url.replace('mysql://', '').split('@')
    user, password = user_pass.split(':')
    password = password.replace('%40', '@')
    host_port, db = host_db.split('/')
    host, port = host_port.split(':')
    
    conn = pymysql.connect(
        host=host,
        user=user,
        password=password,
        database=db,
        port=int(port),
        connect_timeout=10
    )
    print("SUCCESS: Connected to database.")
    conn.close()
except Exception as e:
    print(f"FAILURE: {e}")
