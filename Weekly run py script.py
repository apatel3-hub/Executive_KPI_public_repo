import subprocess
import os

password = os.environ.get('Password')

#Run Refresh for Covid 19 data on aggregated table and upload the table
subprocess.call(r'Covid19_data_profile.py"', shell = True)

#Run sql script for table in HCA_SNDBX 
subprocess.call(rf'echo exit | sqlplus "username/{password} @(DESCRIPTION=    (ADDRESS=      (PROTOCOL=TCP)      (HOST=hostname)      (PORT=1234)    )    (CONNECT_DATA=      (SID=servername)    )  )" "@EXE_COVID_from_FA.sql"', shell = True)

#Send an email
subprocess.call(r'C:\ProgramData\Anaconda3\python.exe "Email_for_completion_covid.py"', shell = True)
