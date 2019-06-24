ssl_check.sh 中 CheckDomains 为域名列表，每个域名空格分开，Alert_Email 为提醒邮箱，不填的话不邮件提醒，Alert_Days 为提前多少天提醒。

sendmail.py 中 mailServer 填写你邮箱smtp服务器的地址，mailServerPort 填写smtp服务器端口，mailFrom 填写邮箱，mailPassword 填写邮箱密码。因为目前很多VPS服务商都将25端口封了所有默认使用SSL协议发送，具体各个邮件服务商的smtp服务器地址、端口信息可以通过 常见邮件服务商SMTP服务器端口查询 这里进行查询。

设置好前面的信息可以 /root/ssl_check.sh 执行一下试试，看能不能正常获取到期时间。

没有问题的话可以在crontab中添加上 0 5 * * * /root/ssl_check.sh 这样每天凌晨5点会检查一次。
