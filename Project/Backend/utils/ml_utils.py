import os
import numpy as np
from tensorflow.keras.models import load_model
import joblib
import logging
import hashlib
from ml_model.feature_extraction import extract_features

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

MODEL = None
LABEL_ENCODER = None

def compute_file_hash(file_path):
    """Compute SHA256 hash of a file."""
    sha256 = hashlib.sha256()
    with open(file_path, 'rb') as f:
        for chunk in iter(lambda: f.read(4096), b''):
            sha256.update(chunk)
    return sha256.hexdigest()

def initialize_model_and_encoder(model_path=None, label_encoder_path=None):
    """
    Initialize the model and label encoder, verifying model integrity.
    
    Args:
        model_path (str): Path to the saved Keras model.
        label_encoder_path (str): Path to the saved label encoder.
    
    Returns:
        bool: True if both model and label encoder are loaded successfully, False otherwise.
    """
    global MODEL, LABEL_ENCODER
    if model_path is None:
        model_path = os.path.join(os.path.dirname(__file__), "..", "ml_model", "deepfake_audio_detector.h5")
        model_path = os.path.normpath(model_path)
    if label_encoder_path is None:
        label_encoder_path = os.path.join(os.path.dirname(__file__), "..", "ml_model", "label_encoder.pkl")
        label_encoder_path = os.path.normpath(label_encoder_path)
    
    logger.info(f"Resolved model path: {model_path}")
    logger.info(f"Resolved label encoder path: {label_encoder_path}")
    if not os.path.exists(model_path):
        logger.error(f"Model file not found at: {model_path}")
        return False
    
    model_hash = compute_file_hash(model_path)
    logger.info(f"Model file SHA256: {model_hash}")
    
    logger.info(f"Loading model from: {model_path}")
    try:
        MODEL = load_model(model_path)
        logger.info("Keras model loaded successfully")
    except Exception as e:
        logger.error(f"Model load failed: {e}")
        return False
    
    if not os.path.exists(label_encoder_path):
        logger.error(f"Label encoder file not found at: {label_encoder_path}")
        return False
    
    logger.info(f"Loading label encoder from: {label_encoder_path}")
    try:
        LABEL_ENCODER = joblib.load(label_encoder_path)
        logger.info(f"Label encoder classes: {LABEL_ENCODER.classes_.tolist()}")
        logger.info("Label encoder loaded successfully")
    except Exception as e:
        logger.error(f"Label encoder load failed: {e}")
        return False
    return True
def predict_audio(file_path, sr=16000, n_mfcc=40, duration=12):
    """
    Predict whether an audio file is real or fake using the trained model.
    
    Args:
        file_path (str): Path to audio file.
        sr (int): Sampling rate.
        n_mfcc (int): Number of MFCC coefficients.
        duration (int): Maximum duration in seconds.
    
    Returns:
        tuple: (prediction, confidence) where prediction is 1 (real) or 0 (fake).
    """
    try:
        if not os.path.exists(file_path):
            logger.error(f"File not found: {file_path}")
            return None, None
        if not file_path.lower().endswith(('.wav', '.mp3', '.flac')):
            logger.error(f"Unsupported file format: {file_path}")
            return None, None

        logger.info(f"Extracting features for: {file_path}")
        features = extract_features(file_path, sr=sr, n_mfcc=n_mfcc, duration=duration)
        if features is None:
            logger.error("Feature extraction failed")
            return None, None

        expected_shape = (1, 128, 128, 3)
        features = np.expand_dims(features, axis=0)
        if features.shape != expected_shape:
            logger.error(f"Unexpected feature shape: {features.shape}, expected: {expected_shape}")
            return None, None
        logger.info(f"Features shape: {features.shape}")

        global MODEL, LABEL_ENCODER
        if MODEL is None or LABEL_ENCODER is None:
            if not initialize_model_and_encoder():
                logger.error("Failed to initialize model or label encoder")
                return None, None

        logger.info("Making prediction")
        prediction = MODEL.predict(features, verbose=0)
        confidence = float(prediction[0][0])
        logger.info(f"Raw probability: {confidence}")

        predicted_class = 1 if confidence > 0.5 else 0
        predicted_label = LABEL_ENCODER.inverse_transform([predicted_class])[0]
        confidence_score = confidence if predicted_class == 1 else 1.0 - confidence

        logger.info(f"Prediction: {predicted_label}, Confidence: {confidence_score:.4f}")
        prediction = 1 if predicted_label == "real" else 0
        return prediction, confidence_score

    except Exception as e:
        logger.error(f"Prediction error: {e}")
        return None, None