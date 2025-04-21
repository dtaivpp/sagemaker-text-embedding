#!/bin/bash

# Set up error handling
set -e

echo "Starting initialization script..."
# Define variables
source .env
export REPO_URL="https://huggingface.co/abhinand/$REPO_NAME"
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TARGET_DIR="$SCRIPT_DIR"
export ARCHIVE_NAME="$ENDPOINT_NAME.tar.gz"

# Check if the MedEmbed directory already exists
if [ -d "$SCRIPT_DIR/$REPO_NAME" ]; then
    echo "$REPO_NAME directory already exists. Skipping clone step."
else
    # Clone the MedEmbed repository
    echo "Cloning $REPO_URL..."
    git clone --depth=1 $REPO_URL 

fi

# Check if the code directory exists in the current location
if [ -d "$SCRIPT_DIR/code" ]; then
    echo "Code directory found in the current location."
else
    echo "Error: code directory not found in $SCRIPT_DIR"
    exit 1
fi

# Copy the code directory into the MedEmbed-Large-v0.1 directory
echo "Copying code directory..."
cp -r "$SCRIPT_DIR/code" "$SCRIPT_DIR/$REPO_NAME/code"

# Remove the .git directory
echo "Removing .git directory..."
rm -rf "$SCRIPT_DIR/$REPO_NAME/.git"
cd "$SCRIPT_DIR/$REPO_NAME"

# Create a tar archive of the medembed directory
echo "Creating tar archive..."
tar -czvf "$ARCHIVE_NAME" .
echo "Archive created: $ARCHIVE_NAME"

echo "Uploading archive to S3..."
aws s3 cp "$ARCHIVE_NAME" s3://$BUCKET_NAME/$ARCHIVE_NAME --region $REGION
echo "Uploaded archive to S3: $ARCHIVE_NAME"
cd "code"

echo "Deploying to SageMaker..."
python deploy.py

echo "Running tests..."
python test.py
