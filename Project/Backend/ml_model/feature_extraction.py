import librosa
import numpy as np
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

try:
    from tensorflow.keras.applications.efficientnet import preprocess_input
    logger.info("Using preprocess_input from tensorflow.keras.applications.efficientnet")
except ImportError:
    logger.error("Failed to import preprocess_input. Install 'tensorflow' correctly.")
    preprocess_input = None

def extract_features(file_path, sr=16000, n_mfcc=40, duration=12):
    """
    Extract MFCC features from an audio file, matching ML team's training preprocessing.
    
    Args:
        file_path (str): Path to audio file (WAV, MP3, FLAC).
        sr (int): Sampling rate.
        n_mfcc (int): Number of MFCC coefficients.
        duration (int): Maximum duration in seconds.
    
    Returns:
        numpy.ndarray: Preprocessed MFCC features (128, 128, 3), or None if processing fails.
    """
    try:
        logger.info(f"Processing file: {file_path}")
        y, _ = librosa.load(file_path, sr=sr, duration=duration, mono=True)
        if len(y) < sr * 0.1:
            logger.warning(f"Skipping short file: {file_path}")
            return None
        
        # Noise reduction: estimate noise from first 100ms
        noise_sample = y[:int(sr * 0.1)]
        if len(noise_sample) > 0:
            noise_mean = np.mean(noise_sample)
            noise_std = np.std(noise_sample)
            threshold = noise_mean + 3 * noise_std
            y = np.where(np.abs(y) < threshold, y * 0.1, y)
            logger.info(f"Noise reduction applied: mean={noise_mean:.6f}, std={noise_std:.6f}, threshold={threshold:.6f}")
        
        # Extract MFCCs
        mfcc = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=n_mfcc, hop_length=512, n_fft=2048, dtype=np.float32)
        logger.info(f"Raw MFCC shape: {mfcc.shape}, Min: {mfcc.min():.6f}, Max: {mfcc.max():.6f}, Mean: {mfcc.mean():.6f}, Std: {mfcc.std():.6f}")
        
        # Resize MFCCs
        mfcc_resized = librosa.util.fix_length(mfcc, size=224, axis=1, mode='constant')
        if mfcc_resized.shape[1] < 224:
            padding = 224 - mfcc_resized.shape[1]
            mfcc_resized = np.pad(mfcc_resized, ((0, 0), (0, padding)), mode='constant')
        mfcc_img = np.resize(mfcc_resized, (128, 128))
        
        # Create 3-channel input
        mfcc_img_3ch = np.stack((mfcc_img, mfcc_img, mfcc_img), axis=-1).astype(np.float32)
        logger.info(f"MFCC 3ch shape: {mfcc_img_3ch.shape}, Min: {mfcc_img_3ch.min():.6f}, Max: {mfcc_img_3ch.max():.6f}, Mean: {mfcc_img_3ch.mean():.6f}, Std: {mfcc_img_3ch.std():.6f}")
        
        # Apply EfficientNet preprocessing
        if preprocess_input:
            mfcc_img_3ch = preprocess_input(mfcc_img_3ch)
            logger.info(f"Preprocessed shape: {mfcc_img_3ch.shape}, Min: {mfcc_img_3ch.min():.6f}, Max: {mfcc_img_3ch.max():.6f}, Mean: {mfcc_img_3ch.mean():.6f}, Std: {mfcc_img_3ch.std():.6f}")
        else:
            logger.warning("preprocess_input not available")
        
        return mfcc_img_3ch
    except Exception as e:
        logger.error(f"Error processing {file_path}: {e}")
        return None