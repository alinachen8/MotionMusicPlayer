import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report
import joblib
import os

class GestureClassifier:
    def __init__(self):
        self.scaler = StandardScaler()
        self.model = RandomForestClassifier(n_estimators=100, random_state=42)
    
    def prepare_data(self, csv_file, label):
        """Load and prepare data from a CSV file"""
        df = pd.read_csv(csv_file)
        # Add label column
        df['label'] = label
        return df
    
    def train(self, data_files, labels):
        """Train the classifier on multiple gesture data files"""
        all_data = []
        
        # Load and combine all data
        for file, label in zip(data_files, labels):
            df = self.prepare_data(file, label)
            all_data.append(df)
        
        combined_data = pd.concat(all_data, ignore_index=True)
        
        # Prepare features and labels
        feature_columns = ['accel_x', 'accel_y', 'accel_z', 
                         'rotation_x', 'rotation_y', 'rotation_z',
                         'pitch', 'roll', 'yaw']
        
        X = combined_data[feature_columns]
        y = combined_data['label']
        
        # Scale features
        X = self.scaler.fit_transform(X)
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )
        
        # Train model
        self.model.fit(X_train, y_train)
        
        # Evaluate
        y_pred = self.model.predict(X_test)
        print("\nClassification Report:")
        print(classification_report(y_test, y_pred))
        
        return self.model.score(X_test, y_test)
    
    def predict(self, data):
        """Predict gesture from new data"""
        # Ensure we have the right columns
        feature_columns = ['accel_x', 'accel_y', 'accel_z', 
                         'rotation_x', 'rotation_y', 'rotation_z',
                         'pitch', 'roll', 'yaw']
        
        if isinstance(data, pd.DataFrame):
            X = data[feature_columns]
        else:
            # If data is a single row as array/list
            X = np.array(data).reshape(1, -1)
        
        # Scale features
        X = self.scaler.transform(X)
        
        # Predict
        return self.model.predict(X)[0]
    
    def save_model(self, path):
        """Save the trained model and scaler"""
        model_data = {
            'model': self.model,
            'scaler': self.scaler
        }
        joblib.dump(model_data, path)
    
    @classmethod
    def load_model(cls, path):
        """Load a trained model"""
        model_data = joblib.load(path)
        classifier = cls()
        classifier.model = model_data['model']
        classifier.scaler = model_data['scaler']
        return classifier

def main():
    # Example usage
    data_dir = "data"
    gesture_types = ["like", "rotate_next", "stop"]
    
    # Get all CSV files for each gesture type
    data_files = []
    labels = []
    
    for gesture in gesture_types:
        gesture_dir = os.path.join(data_dir, gesture)
        if os.path.exists(gesture_dir):
            for file in os.listdir(gesture_dir):
                if file.endswith(".csv"):
                    data_files.append(os.path.join(gesture_dir, file))
                    labels.append(gesture)
    
    if not data_files:
        print("No data files found!")
        return
    
    # Create and train classifier
    classifier = GestureClassifier()
    accuracy = classifier.train(data_files, labels)
    print(f"\nModel accuracy: {accuracy:.2f}")
    
    # Save the model
    classifier.save_model("gesture_model.joblib")
    print("\nModel saved as 'gesture_model.joblib'")

if __name__ == "__main__":
    main() 