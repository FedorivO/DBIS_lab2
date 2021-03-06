"""Лабораторна робота №1
Федорів О. , КМ-83
Варіант 11
Порівняти середній бал з Фізики у кожному регіоні
у 2020 та 2019 роках
серед тих, кому було зараховано тест
"""

import psycopg2
import psycopg2.errorcodes
import csv
import itertools
import time
import datetime


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

# видалення таблиці, якщо така існує
cursor.execute('DROP TABLE IF EXISTS zno_data;')
conn.commit()


def create_table():

    with open("Odata2019File.csv", "r", encoding="cp1251") as csv_file:
        header = csv_file.readline()
        header = header.split(';')
        header = [elem.strip('"') for elem in header]
        columns = "\n\tYear INT,"
        header[-1] = header[-1].rstrip('"\n')


        for elem in header:

            if 'Ball' in elem:
                columns += '\n\t' + elem + ' REAL,'
            elif elem == 'Birth':
                columns += '\n\t' + elem + ' INT,'
            elif elem == "OUTID":
                columns += '\n\t' + elem + ' VARCHAR(40) PRIMARY KEY,'
            else:
                columns += '\n\t' + elem + ' VARCHAR(255),'

        create_table_query = '''CREATE TABLE IF NOT EXISTS zno_data (''' + columns.rstrip(',') + '\n);'
        cursor.execute(create_table_query)
        conn.commit()
        return header

header = create_table()


def insert_from_csv(f, year, conn, cursor, time_file):
    start_time = time.time()

    with open(f, "r", encoding="cp1251") as csv_file:
        print(f + ' ...')
        csv_reader = csv.DictReader(csv_file, delimiter=';')
        batches_inserted = 0
        batch_size = 50
        inserted_all = False

        # поки не вставили всі рядки
        while not inserted_all:
            try:
                insert_query = '''INSERT INTO zno_data (year, ''' + ', '.join(header) + ') VALUES '
                count = 0
                for row in csv_reader:
                    count += 1

                    # обробляємо запис, для знаходження середнього необхідний запис чисел через крапку
                    for key in row:
                        if row[key] == 'null':
                            pass
                        elif key.lower() != 'birth' and 'ball' not in key.lower():
                            row[key] = "'" + row[key].replace("'", "''") + "'"
                        elif 'ball100' in key.lower():
                            row[key] = row[key].replace(',', '.')
                    insert_query += '\n\t(' + str(year) + ', ' + ','.join(row.values()) + '),'

                    if count == batch_size:
                        count = 0
                        insert_query = insert_query.rstrip(',') + ';'
                        cursor.execute(insert_query)
                        conn.commit()
                        batches_inserted += 1
                        insert_query = '''INSERT INTO zno_data (year, ''' + ', '.join(header) + ') VALUES '

                # якщо досягли кінця файлу
                if count != 0:
                    insert_query = insert_query.rstrip(',') + ';'
                    cursor.execute(insert_query)
                    conn.commit()
                inserted_all = True

            except psycopg2.OperationalError as err:
                if err.pgcode == psycopg2.errorcodes.ADMIN_SHUTDOWN:
                    print("Відбулося падіння бази даних -- очікуйте відновлення з'єднання...")
                    time_file.write(str(datetime.datetime.now()) + " - втрата з'єднання\n")
                    connection_restored = False
                    while not connection_restored:
                        try:
                            # намагаємось підключитись до бази даних
                            conn = create_connection("postgres", "postgres", "admin", "localhost")
                            cursor = conn.cursor()
                            time_file.write(str(datetime.datetime.now()) + " - відновлення з'єднання\n")
                            connection_restored = True
                        except psycopg2.OperationalError:
                            pass

                    print("З'єднання відновлено!")
                    csv_file.seek(0, 0)
                    csv_reader = itertools.islice(csv.DictReader(csv_file, delimiter=';'),
                                                  batches_inserted * batch_size, None)

    end_time = time.time() - start_time
    time_file.write(str(end_time) + "сек. - файл " + f + " оброблено\n")

    return conn, cursor


time_file = open('time.txt', 'w')
conn, cursor = insert_from_csv("Odata2019File.csv", 2019, conn, cursor, time_file)
conn, cursor = insert_from_csv("Odata2020File.csv", 2020, conn, cursor, time_file)

time_file.close()

# виконання завдання відповідно до варіанту
QUERY = '''
SELECT regname AS "Область", year AS "Рік", avg(physBall100) AS "Середній бал"
FROM zno_data
WHERE physTestStatus = 'Зараховано'
GROUP BY regname, year
ORDER BY year, avg(physBall100) DESC;
'''
cursor.execute(QUERY)

# запис результату виконаного завдання у csv файл
with open('result_lab1.csv', 'w', encoding="utf-8") as result_csv:
    csv_writer = csv.writer(result_csv)
    header_row = ['Область', 'Рік', 'Середній бал з фізики']
    csv_writer.writerow(header_row)
    for row in cursor:
        csv_writer.writerow(row)

cursor.close()
conn.close()

