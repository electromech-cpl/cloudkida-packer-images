#!/bin/bash -eux

SSH_USER=centos



echo "==> Cleaning up tmp"
rm -rf /tmp/*


# Remove Bash history
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/${SSH_USER}/.bash_history

sed -i 's/\(kernel.*\)/\1 edd=off/' /boot/grub/grub.conf
