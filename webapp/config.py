import mysql.connector

def get_db_connection():
    connection = mysql.connector.connect(
        host='localhost',
        user='root',
        password='ваш_пароль',
        database='cnbp_production_db'
    )
    return connection
