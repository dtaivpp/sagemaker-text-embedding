import os
import boto3
import json
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
ENDPOINT_NAME = os.getenv("ENDPOINT_NAME")
runtime = boto3.client("sagemaker-runtime")

try:
    response = runtime.invoke_endpoint(
        EndpointName=ENDPOINT_NAME,
        ContentType="application/json",
        Body=json.dumps({"inputs": "Get me a clinical summary of this patient's heart medication history."})
    )

    # Parse the response
    response_body = json.loads(response["Body"].read())
    
    # Check if we have embeddings in the response
    if 'embeddings' in response_body and len(response_body['embeddings']) > 0:
        # Get dimensionality of the first embedding
        embedding_dim = len(response_body['embeddings'][0])
        
        print(f"Embedding dimensionality: {embedding_dim}")
        print("Endpoint call successful!")
    else:
        print(f"Response received but no embeddings found: {response_body}")
        print("Endpoint call may not have returned expected format")
        
except Exception as e:
    print(f"Error calling endpoint: {str(e)}")
    print("Endpoint call failed")