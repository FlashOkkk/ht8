#!/bin/bash

# Змінні
AMI_ID="ami-01bc990364452ab3e"
INSTANCE_TYPE="t2.micro"
KEY_NAME="aws-devops-2024"
SECURITY_GROUP_ID="sg-0b1dbb5274b0e3edc"
SUBNET_ID="subnet-00502f7647778e0df"
USER_DATA_FILE="user-data.sh"

# Перевірка наявності user-data.sh
if [ ! -f "$USER_DATA_FILE" ]; then
  echo "Error: User data file $USER_DATA_FILE not found!"
  exit 1
fi

# Запуск EC2 інстанції
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --security-group-ids $SECURITY_GROUP_ID \
  --subnet-id $SUBNET_ID \
  --user-data file://$USER_DATA_FILE \
  --query "Instances[0].InstanceId" --output text)

if [ $? -eq 0 ]; then
  echo "EC2 instance $INSTANCE_ID launched successfully!"
else
  echo "Failed to launch EC2 instance."
  exit 1
fi

# Відкриття портів 80 і 443 через AWS CLI
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0

if [ $? -eq 0 ]; then
  echo "Ports 80 and 443 opened successfully in Security Group $SECURITY_GROUP_ID!"
else
  echo "Failed to open ports 80 and 443."
  exit 1
fi
