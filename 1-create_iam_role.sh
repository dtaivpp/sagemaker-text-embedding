#!/bin/bash
# Script to create IAM role for SageMaker with necessary permissions

# Create the IAM role with trust relationship
aws iam create-role \
    --role-name SageMaker-MedEmbed-Role \
    --assume-role-policy-document file://trust-policy.json

# Attach AWS managed policies
aws iam attach-role-policy \
    --role-name SageMaker-MedEmbed-Role \
    --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess

aws iam attach-role-policy \
    --role-name SageMaker-MedEmbed-Role \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

aws iam attach-role-policy \
    --role-name SageMaker-MedEmbed-Role \
    --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess

# Create and attach custom policy for specific S3 bucket access
aws iam put-role-policy \
    --role-name SageMaker-MedEmbed-Role \
    --policy-name MedEmbed-S3-Access \
    --policy-document file://sagemaker-policy.json

echo "IAM role SageMaker-MedEmbed-Role created with necessary permissions"
echo "Use the following role ARN in your SageMaker deployment:"
aws iam get-role --role-name SageMaker-MedEmbed-Role --query 'Role.Arn' --output text