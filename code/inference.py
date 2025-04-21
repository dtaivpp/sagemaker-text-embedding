from sentence_transformers import SentenceTransformer

model = SentenceTransformer('/opt/ml/model')

def model_fn(model_dir):
    print(f"Loading model from: {model_dir}")
    model = SentenceTransformer(model_dir)
    print("Model loaded.")
    return model

def predict_fn(data, model):
    inputs = data.get("inputs") or data
    if isinstance(inputs, str):
        inputs = [inputs]
    embeddings = model.encode(inputs, convert_to_numpy=True)
    return {"embeddings": embeddings.tolist()}