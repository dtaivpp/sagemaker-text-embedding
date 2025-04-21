# Makefile for MedEmbed deployment process

# Load environment variables from .env file
include .env
export

.PHONY: all check-env check-aws-cli check-python-reqs check-iam-role run-init deploy clean

all: check-env check-aws-cli check-python-reqs check-iam-role run-init

# Check required environment variables
check-env:
	@echo "Checking environment variables..."
	@if [ -z "$(BUCKET_NAME)" ]; then echo "ERROR: BUCKET_NAME is not set in .env file"; exit 1; fi
	@if [ -z "$(ACCOUNT_ID)" ]; then echo "ERROR: ACCOUNT_ID is not set in .env file"; exit 1; fi
	@if [ -z "$(ENDPOINT_NAME)" ]; then echo "ERROR: ENDPOINT_NAME is not set in .env file"; exit 1; fi
	@if [ -z "$(REPO_NAME)" ]; then echo "ERROR: REPO_NAME is not set in .env file"; exit 1; fi
	@echo "✅ Environment variables are properly set"

# Verify AWS CLI is installed and authenticated
check-aws-cli:
	@echo "Checking AWS CLI installation and authentication..."
	@which aws > /dev/null || (echo "ERROR: AWS CLI is not installed"; exit 1)
	@aws sts get-caller-identity > /dev/null || (echo "ERROR: AWS CLI not authenticated. Run 'aws configure'"; exit 1)
	@echo "✅ AWS CLI is installed and authenticated"

# Check Python requirements for SageMaker
check-python-reqs:
	@echo "Checking Python requirements..."
	@echo "Checking root requirements.txt..."
	@echo "Installing root requirements..."
	@pip install -r requirements.txt
	@echo "✅ Python requirements are satisfied"

# Check and create IAM role if needed
check-iam-role:
	@echo "Checking if SageMaker IAM role exists..."
	@if aws iam get-role --role-name SageMaker-MedEmbed-Role > /dev/null 2>&1; then \
		echo "✅ IAM role SageMaker-MedEmbed-Role already exists"; \
	else \
		echo "Creating IAM role for SageMaker..."; \
		bash ./1-create_iam_role.sh; \
	fi

# Run initialization script
run-init:
	@echo "Running initialization script..."
	@bash ./2-initialize.sh

# Clean up any temporary files
clean:
	@echo "Cleaning up temporary files..."
	@rm -f *.log
	@find . -name "__pycache__" -type d -exec rm -rf {} +;

# Help information
help:
	@echo "Available targets:"
	@echo "  all              : Run complete deployment process (default)"
	@echo "  check-env        : Verify environment variables are set"
	@echo "  check-aws-cli    : Check AWS CLI installation and authentication"
	@echo "  check-python-reqs: Check Python requirements"
	@echo "  check-iam-role   : Check and create IAM role if needed"
	@echo "  run-init         : Run initialization script"
	@echo "  clean            : Clean up temporary files"
	@echo "  help             : Show this help information"