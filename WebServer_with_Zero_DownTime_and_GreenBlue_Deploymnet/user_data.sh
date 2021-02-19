#!/bin/bash
yum -y update
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y epel-release
yum update -y
yum install nginx -y
MYIP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

cat <<EOF > /usr/share/nginx/html/index.html
<html>
<body bgcolor="black">
<h2><font color="gold">Build by Power of Terraform <font color="red">v0.14</font></h2><br><p>

<font color="purple">Created by: <font color="white">DEBIL<br>
<font color="green">Server private-IP: <font color="aqua">$MYIP<br>
<font color="green">Host: <font color="aqua">$(hostname -f)<br><br>

<font color="magenta">
<b>Version 6.0</b>

</body>
</html>
EOF

service nginx start
chkconfig nginx on