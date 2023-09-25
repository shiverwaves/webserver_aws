#!/bin/bash

# create s3 bucket with a random hash at the end of the name
printf "\n############ CREATING S3 BUCKET ############\n"

# get aws default region configured
REGION=`aws configure list --output text | grep "region" | awk '{print $2}'`
sleep 1

aws s3api create-bucket --bucket "tf-rm-st-bkt-`echo $RANDOM | md5sum | head -c 7`" --region $REGION
sleep 1

BUCKET_NAME=`aws s3api list-buckets --output text | grep "BUCKETS" | head -n 1 | awk '{print $3}'`
sleep 1

aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled
sleep 1

aws s3api put-bucket-encryption --bucket $BUCKET_NAME --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
sleep 1

# create dynamodb table with a matching hash at the end of the name
printf "\n############ CREATING DYNAMODB TABLE ############\n"
aws dynamodb create-table --table-name "tf-rm-st-tbl-`echo $BUCKET_NAME | awk -F '-' '{print $5}'`" --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST
sleep 1

TABLE_NAME=`aws dynamodb list-tables | awk '/TableNames/{getline; print}' | awk -F '"' '{print $2}'`
sleep 1

# print out bucket and table information
printf "\n############ UPDATING TF FILES ############\n"
echo "AWS_REGION=$REGION"
sed -i "s/\"[a-z][a-z]-[a-z].*-[0-9]\"/\"$REGION\"/g" main.tf
echo "AWS_BUCKET_NAME=$BUCKET_NAME"
sed -i "s/\"tf-rm-st-bkt.*\"/\"$BUCKET_NAME\"/g" main.tf 
echo "AWS_TABLE_NAME=$TABLE_NAME"
sed -i "s/\"tf-rm-st-tbl.*\"/\"$TABLE_NAME\"/g" main.tf  
sleep 1

# updating repo files with updated remote state
printf "\n############ UPDATING GITHUB ############\n"
git add main.tf
git commit -m "updating terraform remote_state"
git push