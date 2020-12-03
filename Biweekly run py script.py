import subprocess
import os

password = os.environ.get('Password')


#Run ER sql script for table in HCA_SNDBX 
subprocess.call(rf'echo exit | sqlplus "username/{password} @(DESCRIPTION=    (ADDRESS=      (PROTOCOL=TCP)      (HOST=hostname)      (PORT=1234)    )    (CONNECT_DATA=      (SID=server)    )  )" "@ER_IMPACTABLE_OFFICE VISIT.sql"', shell = True)

#Run sql script for table in HCA_SNDBX 
subprocess.call(rf'echo exit | sqlplus "username/{password} @(DESCRIPTION=    (ADDRESS=      (PROTOCOL=TCP)      (HOST=hostname)      (PORT=1234)    )    (CONNECT_DATA=      (SID=server)    )  )" "@TeleHealth_Visits.sql"', shell = True)

#Send an email
subprocess.call(r'C:\ProgramData\Anaconda3\python.exe "Email_for_completion.py"', shell = True)
