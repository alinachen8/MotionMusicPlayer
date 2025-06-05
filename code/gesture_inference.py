from feature_extraction import extract_features
import numpy as np
import joblib

scaler_path = '/Users/pranavxiyer/Documents/northwestern/classes/first/spring/machine learning and sensing/project/scaler/standard_scaler.joblib'

random_forest_path = '/Users/pranavxiyer/Documents/northwestern/classes/first/spring/machine learning and sensing/project/models/random_forest.joblib'

idx_to_label = {
    0: 'rotate_next',
    1: 'rotate_prev',
    2: 'like',
    3: 'stop',
    4: 'other'
}

# Inference, defaults to random forest / other model is vanilla neural network

def gesture_inference(df, sampling_frequency, random_forest=True):
    features = extract_features(df, sampling_frequency)
    features_array = np.array(list(features.values()))
    features_array = features_array.reshape(1, -1)

    scaler = joblib.load(scaler_path)
    features_array = scaler.transform(features_array)

    if random_forest:
        model = joblib.load(random_forest_path)
    else:
        print('neural network WIP')
        return
    
    prediction = model.predict(features_array)
    label_prediction = idx_to_label[prediction[0]]
    return label_prediction







    
