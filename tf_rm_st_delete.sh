#!/bin/bash

# get a list of table names
TABLES=( `aws dynamodb list-tables --output text | grep "TABLENAMES" | awk '{print $2}'` )

# for each table...
for TABLE in ${TABLES[@]}
do
    # delete the table
    printf "\n############ DELETING TABLE $TABLE ############\n"
    aws dynamodb delete-table --table-name $TABLE
    sleep 1
    
done

# get a list of bucket names
BUCKETS=( `aws s3api list-buckets --output text | grep "BUCKETS" | awk '{print $3}'` )

# for each bucket...
for BUCKET in ${BUCKETS[@]};
do
    # empty the bucket
    printf "\n############ EMPTYING BUCKET $BUCKET ############\n"
    aws s3 rm s3://$BUCKET --recursive
    sleep 1
    
    # remove all delete markers and versioned objects from the bucket
    printf "\n############ REMOVING VERSIONED OBJECTS FROM BUCKET $BUCKET ############\n"
    aws s3api delete-objects --bucket $BUCKET --delete "`aws s3api list-object-versions --bucket $BUCKET --output=json --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}'`"
    sleep 1
    
    printf "\n############ REMOVING DELETE MARKERS FROM BUCEKT $BUCKET ############\n"
    aws s3api delete-objects --bucket $BUCKET --delete "`aws s3api list-object-versions --bucket $BUCKET --output=json --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}'`"
    sleep 1
    
    # delete the bucket
    printf "\n############ DELETING BUCKET ############\n"
    aws s3 rb s3://$BUCKET 
    sleep 1
    
done