#!/bin/bash -eux

# Add rocky user to sudoers.
echo "rocky        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
sed -re 's/^(PasswordAuthentication)([[:space:]]+)no/\1\2yes/' -i.`date -I` /etc/ssh/sshd_config
sed -i 's/ssh_pwauth:   0/ssh_pwauth:   1/g' /etc/cloud/cloud.cfg
systemctl restart sshd
# Disable daily apt unattended updates.

#Start httpd, mariadb
echo "==> start httpd,  mariadb"
systemctl enable httpd
systemctl start httpd
# firewall-cmd --add-service=http --permanent 
# firewall-cmd --reload
systemctl enable mariadb.service
systemctl start mariadb.service

#Setup mariadb User and DB
echo "==> Setup mariadb User and DB"
cat <<EOF >> /tmp/setup.mysql
CREATE DATABASE wordpress_db;
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'student';
GRANT ALL ON wordpress_db.* TO 'admin'@'localhost';
FLUSH PRIVILEGES;
EOF

mysqladmin -u root password 'student'
$(mysql wordpress_db -u root --password='student' >/dev/null 2>&1 </dev/null); (( $? != 0 ))
mysql -u root --password='student' < /tmp/setup.mysql
$(mysql wordpress_db -u root --password='student' >/dev/null 2>&1 </dev/null); (( $? !=0))


#Setup httpd vhost file
echo "==> Setup httpd vhost file"
# # Retrieve the EC2 instance public IP using metadata
# PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

# # Store the EC2 instance public IP in a variable
# IP_VARIABLE="$PRIVATE_IP"


cat <<EOF >> /etc/httpd/conf.d/site.conf
<virtualhost *:80>
servername  localhost
Documentroot "/var/www/html/wordpress"

<Directory "/var/www/html/wordpress">
    Options -Indexes +FollowSymLinks
    AllowOverride All
    DirectoryIndex index.php  index.html index.htm
    Require all granted
</Directory>
<Location />
 SetOutputFilter DEFLATE
 BrowserMatch ^Mozilla/4 gzip-only-text/html
 BrowserMatch ^Mozilla/4\.0[678] no-gzip
 BrowserMatch \bMSI[E] !no-gzip !gzip-only-text/html
 SetEnvIfNoCase Request_URI \.(?:gif|jpe?g|png|swf|flv|pdf|exe|t?gz|zip|bz2|sit|rar)$ no-gzip dont-vary
</Location>
<Files ~ "\.(css|js|html|htm|txt|json|xml)$">
 SetOutputFilter DEFLATE
</Files>
KeepAlive On
KeepAliveTimeout 15
MaxKeepAliveRequests 200
TimeOut 60
</virtualhost>
EOF
httpd -t

#Download wordpress 
echo "==> Download wordpress"
wget https://wordpress.org/latest.zip
unzip latest.zip
mv wordpress /var/www/html/
chown -R apache:apache /var/www/html/wordpress
chmod -R 775 /var/www/html/wordpress
semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html/wordpress(/.*)?"
restorecon -Rv /var/www/html/wordpress
cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sed -ie "s/database_name_here/wordpress_db/" /var/www/html/wordpress/wp-config.php
sed -ie "s/username_here/admin/g" /var/www/html/wordpress/wp-config.php
sed -ie "s/password_here/student/g" /var/www/html/wordpress/wp-config.php
systemctl restart httpd