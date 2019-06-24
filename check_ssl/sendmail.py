i#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys, smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText

mailTo = sys.argv[1]
mailSubject = sys.argv[2]
mailBodyText = sys.argv[3]
mailServer = 'smtp.163.com'
mailServerPort = '465'
mailFrom = 'xxxx@163.com'
mailPassword = 'xxxxx'
mailAlias = 'Monitor'


print mailTo
print mailSubject
print mailBodyText

msg = MIMEText(mailBodyText, 'plain', 'utf-8')
msg['To'] = mailTo
msg['From'] = '%s <%s>' % (mailAlias, mailFrom)
msg['Subject'] = mailSubject


session = smtplib.SMTP_SSL(mailServer,mailServerPort)
#session = smtplib.SMTP(mailServer,mailServerPort)
#session.set_debuglevel(1)
session.login(mailFrom, mailPassword)
smtpResult = session.sendmail(mailFrom, mailTo, msg.as_string())
session.quit()

if smtpResult:
        errstr = ""
        for recip in smtpResult.keys():
                errstr = """Could not delivery mail to: %s
Server said: %s
%s
%s""" % (recip, smtpResult[recip][0], smtpResult[recip][1], errstr)
        #raise smtplib.SMTPException, errstr
        print errstr
else:
        print 'Message sent successfully.'
