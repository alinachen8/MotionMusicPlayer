import socket
import json
from collections import OrderedDict, deque
import time
import numpy as np
import pandas as pd
from gesture_inference import gesture_inference

HOST = '0.0.0.0'  # Listen on all available network interfaces
PORT = 65433      # Changed port to avoid conflicts

features_dict = OrderedDict([
    ('accel', ['x', 'y', 'z']),
    ('gyro', ['x', 'y', 'z']),
    ('attitude', ['pitch', 'roll', 'yaw'])
])

label_order = ['accel_x', 'accel_y', 'accel_z', 
               'rotation_x', 'rotation_y', 'rotation_z', 
               'pitch', 'roll', 'yaw']

WINDOW_SIZE = 150  # Number of points to use for prediction
OVERLAP = 50      # Number of points to overlap between windows
NEW_POINTS_NEEDED = WINDOW_SIZE - OVERLAP  # Number of new points needed for next prediction
sampling_frequency = 100

def start_socket_server():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind((HOST, PORT))
        s.listen(5)
        print(f"Server listening on {HOST}:{PORT}")
        print("Waiting for connection from iOS app...")
        
        print("\nReady to accept new connection...")
        conn, addr = s.accept()
        print(f"Connected by {addr}")
        
        try:
            with conn:
                print("Starting to receive data...")
                data_buffer = deque(maxlen=WINDOW_SIZE)  # Buffer to store data points with max length
                json_buffer = ""  # Initialize json_buffer
                new_points_collected = 0  # Track new points since last prediction
                
                while True:  # Keep receiving data indefinitely
                    # Receive data
                    data = conn.recv(1024)
                    if not data:
                        print("No data received, connection might be closed")
                        break

                    try:
                        # Add new data to buffer
                        json_buffer += data.decode('utf-8')
                        
                        # Try to find complete JSON objects
                        while True:
                            # Find the first complete JSON object
                            try:
                                # Find the start of a JSON object
                                start = json_buffer.find('{')
                                if start == -1:
                                    # No JSON object found, clear buffer
                                    json_buffer = ""
                                    break
                                
                                # Find the matching closing brace
                                brace_count = 1
                                end = start + 1
                                while brace_count > 0 and end < len(json_buffer):
                                    if json_buffer[end] == '{':
                                        brace_count += 1
                                    elif json_buffer[end] == '}':
                                        brace_count -= 1
                                    end += 1
                                
                                if brace_count == 0:
                                    # We found a complete JSON object
                                    json_str = json_buffer[start:end]
                                    json_dict = json.loads(json_str)
                                    
                                    # Process the JSON object
                                    df_style_dict = {}
                                    for key in features_dict:
                                        data_features = json_dict[key]
                                        for feature in features_dict[key]:
                                            json_feature = data_features[feature]
                                            if key == "accel":
                                                column_name = f"{key}_{feature}"
                                            elif key == "gyro":
                                                column_name = f"rotation_{feature}"
                                            else:
                                                column_name = f"{feature}"
                                            df_style_dict[column_name] = json_feature
                                    
                                    # Add data to buffer
                                    data_buffer.append(df_style_dict)
                                    new_points_collected += 1
                                    
                                    # Process data if we have collected enough new points
                                    if len(data_buffer) == WINDOW_SIZE and new_points_collected >= NEW_POINTS_NEEDED:
                                        # print(f"\nProcessing window of {WINDOW_SIZE} points...")
                                        # print(f"New points collected since last prediction: {new_points_collected}")
                                        
                                        # Convert to DataFrame
                                        df = pd.DataFrame(data_buffer)
                                        
                                        # Get prediction
                                        gesture_prediction = gesture_inference(df, sampling_frequency)
                                        print(f"Gesture prediction: {gesture_prediction}")
                                        
                                        # Create a response dictionary
                                        response = {
                                            "prediction": gesture_prediction,
                                            "status": "complete"
                                        }
                                        
                                        # Send the JSON response
                                        conn.sendall(json.dumps(response).encode('utf-8'))
                                        
                                        # Keep the last OVERLAP points for the next window
                                        for _ in range(WINDOW_SIZE - OVERLAP):
                                            data_buffer.popleft()
                                        
                                        # print(f"Kept {OVERLAP} points for next window...")
                                        
                                        # Reset new points counter
                                        new_points_collected = 0
                                    
                                    # Remove processed JSON from buffer
                                    json_buffer = json_buffer[end:]
                                else:
                                    # Incomplete JSON object, wait for more data
                                    break
                                    
                            except json.JSONDecodeError:
                                # Invalid JSON, remove the problematic part
                                json_buffer = json_buffer[start+1:]
                                continue
                            
                    except Exception as e:
                        print(f"Error processing data: {e}")
                        print(f"Current buffer state: {json_buffer}")
                
        except Exception as e:
            print(f"Error handling connection: {e}")
        finally:
            conn.close()
            print("Connection closed.")

if __name__ == "__main__":
    data = start_socket_server()