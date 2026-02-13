from flask import Flask, render_template, request
from config import get_db_connection

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

# Страница со списком проектов
@app.route('/projects')
def projects():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute('SELECT * FROM Projects')
    data = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('projects.html', projects=data)

# Страница с журналом производства
@app.route('/production_log')
def production_log():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute('''
        SELECT pl.*, p.project_name, pr.product_name, o.operation_name, e.full_name, m.machine_name
        FROM ProductionLog pl
        LEFT JOIN Projects p ON pl.project_id = p.project_id
        LEFT JOIN Products pr ON pl.product_id = pr.product_id
        LEFT JOIN Operations o ON pl.operation_id = o.operation_id
        LEFT JOIN Employees e ON pl.employee_id = e.employee_id
        LEFT JOIN Machines m ON pl.machine_id = m.machine_id
        ORDER BY pl.start_time DESC
        LIMIT 50
    ''')
    data = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('production_log.html', logs=data)

# Страница с аналитическим запросом (трудоёмкость проектов)
@app.route('/analytics/project_hours')
def project_hours():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute('''
        SELECT p.project_name, SUM(pl.duration_hours) AS total_hours
        FROM ProductionLog pl
        JOIN Projects p ON pl.project_id = p.project_id
        GROUP BY p.project_name
    ''')
    data = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('project_hours.html', data=data)

if __name__ == '__main__':
    app.run(debug=True)
