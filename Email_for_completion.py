
import win32com.client
import time 


def send_email(recepeint_email_id,subject_of_email,email_body ):
    outlook = win32com.client.Dispatch('outlook.application')
    mail = outlook.CreateItem(0)
    mail.To = recepeint_email_id
    mail.Subject = subject_of_email
    #mail.Body = 'Hello Automation'
    mail.HTMLBody = email_body
    # To attach a file to the email (optional)
    #mail.Attachments.Add(r'C:\Users\apatel3\Desktop\Test Workbook to auto refresh.xlsx')
    #mail.Attachments.Add(attachment)
    mail.Send()
    print("Your email was sent successfully")

time_finshed = time.strftime('%a, %d %b %Y %I:%M:%S %p')

send_email('email_id', 'EEM Tables refresh completed', f'EEM Tables completed at {time_finshed}')


