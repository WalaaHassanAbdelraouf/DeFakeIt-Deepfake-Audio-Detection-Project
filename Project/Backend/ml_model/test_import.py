try:
    from tensorflow.keras.applications.efficientnet import preprocess_input
    print("Import successful:", preprocess_input)
except ImportError as e:
    print("Import failed:", e)

import librosa
import tensorflow as tf
import sklearn
import numpy
print("librosa version:", librosa.__version__)
print("tensorflow version:", tf.__version__)
print("scikit-learn version:", sklearn.__version__)
print("Numpy version:", numpy.__version__)