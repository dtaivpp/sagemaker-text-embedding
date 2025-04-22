#!/bin/bash
# Script to create IAM role for SageMaker with necessary permissions

# Source environment variables
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found. Please create one based on sample.env"
    exit 1
fi

# Validate required environment variables
if [ -z "$BUCKET_NAME" ]; then
    echo "Error: BUCKET_NAME environment variable is not set in .env file"
    exit 1
fi

echo "Creating IAM role with bucket name: $BUCKET_NAME"

# Define the trust policy JSON inline
TRUST_POLICY_JSON=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "sagemaker.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
)

# Create the IAM role with trust relationship
aws iam create-role \
    --role-name SageMaker-MedEmbed-Role \
    --assume-role-policy-document "$TRUST_POLICY_JSON"

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

# Generate the custom policy JSON with the bucket name from environment variables
# This avoids needing a static file with hardcoded bucket names
POLICY_JSON=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sagemaker:CreateModel",
                "sagemaker:CreateEndpoint",
                "sagemaker:CreateEndpointConfig",
                "sagemaker:DeleteModel",
                "sagemaker:DeleteEndpoint",
                "sagemaker:DeleteEndpointConfig",
                "sagemaker:DescribeModel",
                "sagemaker:DescribeEndpoint",
                "sagemaker:DescribeEndpointConfig",
                "sagemaker:UpdateEndpoint",
                "sagemaker:UpdateEndpointWeightsAndCapacities",
                "sagemaker:InvokeEndpoint"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${BUCKET_NAME}/*",
                "arn:aws:s3:::${BUCKET_NAME}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": "arn:aws:logs:*:*:log-group:/aws/sagemaker/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "cloudwatch:GetMetricData",
                "cloudwatch:GetMetricStatistics"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::*:role/SageMaker-MedEmbed-Role",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "sagemaker.amazonaws.com"
                }
            }
        }
    ]
}
EOF
)

# Create and attach custom policy for specific S3 bucket access
# We're passing the policy JSON directly as a string, not a file reference
aws iam put-role-policy \
    --role-name SageMaker-MedEmbed-Role \
    --policy-name MedEmbed-S3-Access \
    --policy-document "$POLICY_JSON"

echo "IAM role SageMaker-MedEmbed-Role created with necessary permissions"
echo "Use the following role ARN in your SageMaker deployment:"
aws iam get-role --role-name SageMaker-MedEmbed-Role --query 'Role.Arn' --output text