#!/bin/bash
# This bash script is written for the purpose of bootstrapping terraform remote backend
# 12.02.2024

################# VARIABLES #################
REGION="eu-central-1"
PROJECT_NAME="kotys"
BUCKET_NAME="${PROJECT_NAME}-tf-remote-state-bucket-24"
DYNAMODB_TABLE_NAME="tf-lock-table"

#############################################


# Create a new bucket. mb: make bucket
aws s3 mb "s3://${BUCKET_NAME}" --region ${REGION}

# Enable versioning on the bucket
aws s3api put-bucket-versioning --bucket ${BUCKET_NAME} \
    --versioning-configuration Status=Enabled

# Enable bucket key to reduce encryption costs
# Server-side encryption with Amazon S3 managed keys (SSE-S3) AES256 is default encryption
aws s3api put-bucket-encryption --bucket ${BUCKET_NAME} \
    --server-side-encryption-configuration \
    '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}, "BucketKeyEnabled": true}]}'

# Authorize terrafrom IAM User to read and write on state file on s3 bucket by creating a bucket policy
# a generic policy json is in the directory: s3_policy.json 
# get the ARN of the terraform iam user
TF_USER_ARN=$(aws iam get-user --query User.Arn --output text 2>/dev/null)
# sed the values
sed -e "s/RESOURCE/arn:aws:s3:::${BUCKET_NAME}/g" \
    -e "s/KEY/terraform.tfstate/g" \
    -e "s|ARN|${TF_USER_ARN}|g" \
    "$(dirname "$0")/s3_policy.json" > new-policy.json
aws s3api put-bucket-policy --bucket "tf-remote-bucket" --policy file://new-policy.json
rm -f new-policy.json

# Create DynamoDB Table:
aws dynamodb create-table \
  --table-name ${DYNAMODB_TABLE_NAME} \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
  --region ${REGION}
