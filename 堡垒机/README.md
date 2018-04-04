开启了双因素认证，需要把生成随机码的逻辑加入到脚本。

根据 齐治堡垒机访问服务器方法 ，将二维码右边的手动输入码记录下来如 AAAABBBBCCCCDDDD 是一个 16位的码。

在 terminal 中安装oath

mac: brew install oath-toolkit

centos : sudo yum install oathtool

生成六位随机码的方法，测试一下和手机上生成的是否一致

oathtool --base32 --totp "AAAABBBBCCCCDDDD"
接下来拼接字符串 ipa密码+空格+6位码

#!/usr/bin/expect
 
set ipa 
set timeout 10
set totp [exec oathtool --base32 --totp "AAAABBBBCCCCDDDD"]
set server [lindex $argv 0]
spawn ssh -o PreferredAuthentications=password 10.16.68.100 -l $ipa
expect {
    "*assword:*" {send -- "replace-your-password $totp\r";}
    "Clone last session (y/n)*" {send -- "n\r";}   
}
expect {
    "Select server:" {send "$server\r";}
}
expect {
    "*account:*" {send "2\r"; }
}
expect {
    "*$*" {send "sudo su -\r"; }
}
interact
脚本使用方式

$ chmod +x ./blj-example
$ ./blj-example app120
....
[root@app120 ~]#
  
$ ./blj-example 10.16.142.21
....
[root@app201 ~]#
