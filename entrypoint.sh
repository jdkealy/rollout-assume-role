#!/bin/sh
export PATH=$PATH:/root/.local/bin:/usr/local/bin
set -e
mkdir ~/.kube
echo "$KUBE_CONFIG_DATA" | base64 --decode > ~/.kube/config
export KUBECONFIG=~/.kube/config
export t=`aws --version`
mkdir ~/.aws
echo [default] > ~/.aws/credentials
echo aws_access_key_id = "$AWS_ACCESS_KEY_ID" >> ~/.aws/credentials
echo aws_secret_access_key = $"$AWS_SECRET_ACCESS_KEY" >> ~/.aws/credentials
echo $t
echo "ACCESS KEY ID"
cat ~/.aws/credentials

output=$(aws sts assume-role --role-arn $2 --role-session-name AWSCLI-Session);
key=$(echo $output |  jq -r '.Credentials''.AccessKeyId')
secret=$(echo $output | jq -r '.Credentials''.SecretAccessKey')
token=$(echo $output | jq -r '.Credentials''.SessionToken')
export AWS_ACCESS_KEY_ID=$key
export AWS_SECRET_ACCESS_KEY=$secret
export AWS_SESSION_TOKEN=$token
kubectl rollout restart deployment $1 --kubeconfig ~/.kube/config
