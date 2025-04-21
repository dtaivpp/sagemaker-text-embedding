from sagemaker.huggingface import HuggingFaceModel
from sagemaker.serverless import ServerlessInferenceConfig
from dotenv import load_dotenv
from os import getenv

load_dotenv()
ACCOUNT_ID = getenv("ACCOUNT_ID")
BUCKET_NAME = getenv("BUCKET_NAME")
ENDPOINT_NAME = getenv("ENDPOINT_NAME")
MEMORY_SIZE = int(getenv("MEMORY_SIZE", 3072))  # Default to 2048 MB if not set

hf_model = HuggingFaceModel(
    model_data=f"s3://{BUCKET_NAME}/{ENDPOINT_NAME}.tar.gz",
    role=f"arn:aws:iam::{ACCOUNT_ID}:role/SageMaker-MedEmbed-Role",
    entry_point="inference.py",
    transformers_version="4.37",
    pytorch_version="2.1",
    py_version="py310"
)

from botocore.exceptions import ClientError
try:
    hf_model.sagemaker_session.sagemaker_client.describe_endpoint(EndpointName=ENDPOINT_NAME)
    print(f"Endpoint {ENDPOINT_NAME} already exists. Deleting...")
    hf_model.sagemaker_session.delete_endpoint(ENDPOINT_NAME)
    hf_model.sagemaker_session.delete_endpoint_config(ENDPOINT_NAME)
except ClientError as e:
    if "Could not find" in str(e) or e.response['Error']['Code'] == 'ValidationException':
        print(f"Endpoint {ENDPOINT_NAME} does not exist. Proceeding to create.")
    else:
        raise

hf_model.deploy(
    endpoint_name=ENDPOINT_NAME,
    serverless_inference_config=ServerlessInferenceConfig(
        memory_size_in_mb=MEMORY_SIZE,
        max_concurrency=5
    )
)