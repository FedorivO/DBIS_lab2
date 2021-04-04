"""Лабораторна робота №1
Федорів О. , КМ-83
Варіант 11
Порівняти середній бал з Фізики у кожному регіоні
у 2020 та 2019 роках
серед тих, кому було зараховано тест
"""

import psycopg2
import csv


# підключення до бази даних
def create_connection(db_name, db_user, db_password, db_host):
    connection = None
    try:
        connection = psycopg2.connect(
            database=db_name,
            user=db_user,
            password=db_password,
            host=db_host,
            port="5432"
        )
        print("З'єднання з базою даних  успішне")
    except Error as e:
        print(f"{e}")
    return connection

conn = create_connection("postgres", "postgres", "admin", "localhost")
cursor = conn.cursor()



def statistical_query():
    select_query = '''
    SELECT Location.RegName, TestResult.year, max(TestResult.Ball100)
    FROM TestResult JOIN Participant ON
        TestResult.OutID = Participant.OutID
    JOIN Location ON
        Participant.loc_id = Location.loc_id
    WHERE TestResult.TestName = 'Фізика' AND
        TestResult.TestStatus = 'Зараховано'
    GROUP BY Location.RegName, TestResult.year
    '''
    cursor.execute(select_query)

    with open('result_lab2.csv', 'w', encoding="utf-8") as result_csv:
        csv_writer = csv.writer(result_csv)
        header_row = ['Область', 'Рік', 'Середній бал з фізики']
        csv_writer.writerow(header_row)
        for row in cursor:
            csv_writer.writerow(row)


statistical_query()



#conn.commit()
cursor.close()
conn.close()