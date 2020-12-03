import pandas as pd
import win32com.client
import time
import pyodbc
from sqlalchemy import create_engine
from sqlalchemy.types import String
import os 

#refreshes excel file
def refresh_all_files(filepath):
    xlapp = win32com.client.DispatchEx("Excel.Application")
    start_time = time.time()
    wb = xlapp.Workbooks.Open(filepath)
    wb.RefreshAll()
    xlapp.CalculateUntilAsyncQueriesDone()
    wb.Save()
    wb.Close(True)
    xlapp.Quit()
    end_time = time.time()
    time_taken = round((end_time-start_time)/60,1)
    print(f"Your excel workbook was refreshed successfully in {time_taken} minutes")

covid_data_file = "COVID Raw data.xlsx"

refresh_all_files(filepath= covid_data_file)


#reads data from excel
covid_19_raw_df = pd.read_excel(covid_data_file ,sheet_name='Data')


password = os.environ.get('Password')

#connection engine
engine = create_engine(f'oracle://username:{password}@servername')

#autocommit
engine = engine.execution_options(autocommit=True)

connection = engine.connect()

#this step is to identify text/string columns as they need to uploaded in varchar else uploads in some weired format.
obj_cols = covid_19_raw_df.select_dtypes(include=[object]).columns.values.tolist()

#writes the table in oracle
covid_19_raw_df.to_sql(name = 'Covid_19_raw_df', schema='schemaname', con = engine, 
                                    index = False, if_exists = 'replace',chunksize= 100, dtype = {c : String(1000) for c in obj_cols } )

