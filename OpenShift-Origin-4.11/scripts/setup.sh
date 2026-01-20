#!/bin/bash -eux

# Add ec2-user user to sudoers.
echo "ec2-user        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
sed -re 's/^(PasswordAuthentication)([[:space:]]+)no/\1\2yes/' -i.`date -I` /etc/ssh/sshd_config
sed -i 's/ssh_pwauth:   false/ssh_pwauth:   true/g' /etc/cloud/cloud.cfg
systemctl restart sshd
# Disable daily apt unattended updates.
#echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic

wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
tar -xvzf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
mv openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc /usr/bin/
mv openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/kubectl /usr/bin/
rm -rf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit*
sed -i 's/^OPTIONS=.*/OPTIONS="--default-ulimit nofile=32768:65536 --insecure-registry=172.30.0.0\/16"/' /etc/sysconfig/docker

systemctl restart docker

oc cluster up --routing-suffix=127.0.0.1.nip.io --public-hostname=127.0.0.1.compute-1.amazonaws.com
echo "127.0.0.1 127.0.0.1.nip.io" >> /etc/hosts
echo "127.0.0.1 127.0.0.1.compute-1.amazonaws.com" >> /etc/hosts
