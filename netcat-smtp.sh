#!/bin/bash
from=$3
to=$4
 
function err_exit { echo -e 1>&2; exit 1; }
 
if [ $# -ne 4 ]; then
  echo -e "\n Usage error!"
  echo " This script requires four arguments:"
  echo " 1. recepient mail server"
  echo " 2. port (typically 25 or 465)"
  echo " 3. mail from (e.g. from@example.com)"
  echo " 4. mail to (e.g. to@example.com)"
  exit 1
fi
 
# create message
function mail_input { 
  echo "ehlo $(hostname -f)"
  echo "MAIL FROM: <$from>"
  echo "RCPT TO: <$to>"
  echo "DATA"
  echo "From: <$from>"
  echo "To: <$to>"
  echo "Subject: Testing one two three"
  echo "This is only a test. Please do not panic. If this works, then all is well, else all is not well."
  echo "In closing, Lorem ipsum dolor sit amet, consectetur adipiscing elit."
  echo "."
  echo "quit"
}
 
mail_input | nc $1 $2 || err_exit  
