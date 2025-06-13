from feature_extraction import extract_features
import numpy as np
import joblib
import torch
import torch.nn as nn


# Paths for loading models, scalar
scaler_path = '/Users/pranavxiyer/Documents/northwestern/classes/first/spring/machine learning and sensing/MotionMusicPlayer/scaler/scaler.joblib'
random_forest_path = '/Users/pranavxiyer/Documents/northwestern/classes/first/spring/machine learning and sensing/MotionMusicPlayer/models/random_forest.joblib'
model_path = '/Users/pranavxiyer/Documents/northwestern/classes/first/spring/machine learning and sensing/MotionMusicPlayer/models/neural_net.pth'

idx_to_label = {
    0: 'rotate_next',
    1: 'rotate_prev',
    2: 'like',
    3: 'stop',
    4: 'other'
}

# Inference, defaults to random forest / other model is vanilla neural network

def gesture_inference(df, sampling_frequency, random_forest=True):
    scaler = joblib.load(scaler_path)

    if random_forest:
        model = joblib.load(random_forest_path)
    else:
        input_size = 9 * 15  # 9 sensors * 15 features
        output_size = 5  # 5 gesture classes

        model = nn.Sequential(
            nn.Linear(input_size, 256),
            nn.ReLU(),
            nn.BatchNorm1d(256),
            nn.Dropout(0.3),
            
            nn.Linear(256, 128),
            nn.ReLU(),
            nn.BatchNorm1d(128),
            nn.Dropout(0.3),
            
            nn.Linear(128, 64),
            nn.ReLU(),
            nn.BatchNorm1d(64),
            nn.Dropout(0.3),
            
            nn.Linear(64, 32),
            nn.ReLU(),
            nn.BatchNorm1d(32),
            nn.Dropout(0.3),
            
            nn.Linear(32, output_size)
        )

        model.load_state_dict(torch.load(model_path))
        model.eval()

    features = extract_features(df, sampling_frequency)
    features_array = np.array(list(features.values()))
    features_array = features_array.reshape(1, -1)

    features_array = scaler.transform(features_array)
    
    if random_forest:
        prediction = model.predict(features_array)
        label_prediction = idx_to_label[prediction[0]]
    else:
        features_tensor = torch.FloatTensor(features_array)
        with torch.no_grad():
            outputs = model(features_tensor)
            probabilities = torch.softmax(outputs, dim=1)
            prediction = torch.argmax(probabilities, dim=1).item()
            label_prediction = idx_to_label[prediction]
    
    return label_prediction







    
