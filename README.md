# MedEmbed SageMaker Deployment

This repository demonstrates how to deploy a non-standard text embedding model (MedEmbed) to Amazon SageMaker and query it. MedEmbed is a specialized embedding model for medical text, providing better semantic representations for healthcare applications.

## Overview

This project shows how to:
- Set up the required AWS IAM roles and permissions
- Package and upload a custom model to S3
- Deploy the model to a SageMaker endpoint
- Query the model to get embeddings for medical text

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI installed and configured
- Python 3.8+ with pip
- Git

## Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/dtaivpp/sagemaker-text-embedding.git
   cd sagemaker-embedding-deployment
   ```

2. **Set up environment variables**
   ```bash
   cp sample.env .env
   # Edit the .env file with your AWS details
   ```

3. **Run the deployment**
   ```bash
   make
   ```

## Step-by-Step Instructions

### 1. Configure Your Environment

Copy the sample environment file and edit it with your AWS details:

```bash
cp sample.env .env
```

Required variables:
- `BUCKET_NAME`: Your S3 bucket name for model artifacts
- `ACCOUNT_ID`: Your AWS account ID
- `ENDPOINT_NAME`: Name for your SageMaker endpoint
- `REPO_NAME`: Repository name (MedEmbed-Large-v0.1 or MedEmbed-Small-v0.1)
- `REGION`: AWS region (default: us-east-1)

### 2. Run the Makefile

The included Makefile automates the entire deployment process:

```bash
make
```

This will:
- Verify your environment variables are set
- Check AWS CLI installation and authentication
- Install required Python packages
- Create IAM role if it doesn't exist
- Initialize and deploy the model

### 3. Test Your Endpoint

After deployment, the test script will automatically run to verify the endpoint. You can also run it manually:

```bash
python code/test.py
```

The script will:
- Send a sample query to your endpoint
- Display the resulting embedding
- Show the dimensionality of the embedding
- Confirm if the call was successful

## Project Structure

```
.
├── 1-create_iam_role.sh     # Script to set up AWS IAM role
├── 2-initialize.sh          # Script to package and deploy the model
├── Makefile                 # Automates the deployment process
├── README.md                # This documentation
├── sample.env               # Template for environment variables
├── sagemaker-policy.json    # IAM policy for SageMaker
├── trust-policy.json        # Trust policy for IAM role
└── code/
    ├── deploy.py            # Deployment script for SageMaker
    ├── inference.py         # Inference handler for the model
    ├── requirements.txt     # Python dependencies
    └── test.py              # Script to test the endpoint
```

## Customization

You can choose between two model sizes:
- **MedEmbed-small-v0.1**: Faster, requires less resources
- **MedEmbed-base-v0.1**: Faster, requires less resources
- **MedEmbed-Large-v0.1**: More accurate, requires more resources

To change the model size, update the `REPO_NAME` and `MODEL_NAME` variables in your `.env` file.

## Troubleshooting

- **AWS Authentication Issues**: Run `aws configure` to set up your credentials
- **Endpoint Deployment Failures**: Check CloudWatch logs for the endpoint
- **Python Dependency Issues**: Make sure all requirements are installed with `pip install -r code/requirements.txt`

## Cost Management

Remember that running a SageMaker endpoint incurs costs. To avoid unnecessary charges:
```bash
aws sagemaker delete-endpoint --endpoint-name <ENDPOINT_NAME>
aws sagemaker delete-endpoint-config --endpoint-config-name <ENDPOINT_NAME>
aws sagemaker delete-model --model-name <ENDPOINT_NAME>
```

## License

This project is provided as an example and is available under the MIT License.