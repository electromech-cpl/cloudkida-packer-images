#!/bin/bash -eux

# Add ubuntu user to sudoers.
echo "ubuntu        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
sed -re 's/^(PasswordAuthentication)([[:space:]]+)no/\1\2yes/' -i.`date -I` /etc/ssh/sshd_config
systemctl restart sshd
# Disable daily apt unattended updates.
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic

    