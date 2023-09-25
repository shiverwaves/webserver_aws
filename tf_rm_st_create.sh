#!/bin/bash

# create s3 bucket with a random hash at the end of the name
printf "\n############ CREATING S3 BUCKET ############\n"
aws s3api create-bucket --bucket "tf-rm-st-bkt-`echo $RANDOM | md5sum | head -c 7`"
sleep 1

BUCKET_NAME=`aws s3api list-buckets | grep '"Name"' | awk -F '"' '{print $4}'`
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
printf "\n############ GENERATING OUTPUT ############\n"
echo "AWS_REGION: $REGION"
echo "AWS S3 BUCKET NAME: $BUCKET_NAME"
echo "AWS DYNAMODB TABLE NAME: $TABLE_NAME"