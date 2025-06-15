# 🎧 DeFakeIt-Deepfake-Audio-Detection

This project aims to detect synthetic (deepfake) audio using Convolutional Neural Networks (CNNs) with strong emphasis on audio preprocessing, spectrogram-based features, and model comparison across several architectures like Custom CNN, MobileNet, EfficientNetB0, ResNet and VGG16.

---

## 📦 Dataset Overview

The Fake-or-Real dataset used consists of audio clips divided into:

- real: Human-recorded speech
- fake: AI-generated speech

Split:
- Total samples: 69,300
- Training: 53,868 (77.7%)
- Validation: 10,798 (15.6%)
- Testing: 4,634 (6.7%)

---

## 🔍 Preprocessing 🔧

A multi-step preprocessing pipeline was applied to each audio file:

### 1. Audio Standardization
- All audio clips were converted to mono and resampled to 16,000 Hz.
- Each clip was truncated/padded to 12 seconds to ensure uniformity.

### 2. Noise Reduction
- A simple noise profile was calculated from the first 100ms of each file and subtracted.

### 3. Feature Extraction
- MFCCs (Mel-Frequency Cepstral Coefficients)
- Spectral Centroid, Rolloff, Bandwidth, and Zero-Crossing Rate
- MFCCs were resized to 128×128 and stacked to form 3-channel images for compatibility with pretrained CNN models.

---

## 🧠 Models Trained

### ✅ Custom CNN
- Trained from scratch on extracted MFCC images.
- Final testing Accuracy: 84%
- Model was saved in .h5 format for deployment.

### ✅ ResNet50
- Final testing Accuracy: 85%
- complex but very stable in terms of learning.
  
### ✅ MobileNet
- Final testing Accuracy: 89%
- Lightweight and fast, good for mobile deployment.

### ✅ VGG16
- Final testing Accuracy: 90%
- Heavier but very stable in terms of learning.
  
### ✅ EfficientNetB0
- Final testing Accuracy: 92%
- Excellent trade-off between size and performance.


---

## 📊 Evaluation

Each model was evaluated on:

- Accuracy
- Loss
- ROC Curves
- Confusion Matrix

