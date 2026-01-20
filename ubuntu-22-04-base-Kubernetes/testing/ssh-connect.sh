#!/bin/bash -eux
# Retrieve the EC2 instance public IP using metadata
PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

# Store the EC2 instance public IP in a variable
IP_VARIABLE="$PUBLIC_IP"

# Store Username
USERNAME=ubuntu
# Store testing cmd
SCRIPT="date"

echo "==> RUN Testing CMD"
#SSHPASS='student' sshpass -e ssh $USERNAME@$IP_VARIABLE $SCRIPT
echo "==> Done Testing CMD"

echo "==> Confirm installation by checking the version of kubectl"
kubectl version --client && kubeadm version