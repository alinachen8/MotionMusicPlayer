import socket
import json
from collections import OrderedDict
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

X = []
NUM_POINTS = 180

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
                data_buffer = []  # Buffer to store data points
                json_buffer = ""  # Buffer for incomplete JSON strings
                
                while len(data_buffer) < NUM_POINTS:  # Only continue while we need more points
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
                
                # Process the collected data
                print(f"\nCollected {NUM_POINTS} data points. Processing...")
                # print("DATA BUFFER")
                # print(data_buffer)
                
                # Convert to numpy array (commented out but kept for reference)
                # for row_dict in data_buffer:
                #     row = []
                #     for key in label_order:
                #         row.append(row_dict[key])
                #     X.append(np.array(row))
                
                # Convert to DataFrame
                df = pd.DataFrame(data_buffer)
                # print("\nDataFrame:")
                # print(df)
                
                print("Data collection complete. Exiting...")
                # add inference time
                start_time = time.time()
                gesture_prediction = gesture_inference(df, 100, random_forest=True)
                inference_time = time.time() - start_time
                
                # Create a response dictionary
                response = {
                    "prediction": gesture_prediction,
                    "status": "complete"
                }
                
                # Send the JSON response
                conn.sendall(json.dumps(response).encode('utf-8'))
                return df, gesture_prediction, inference_time
                
        except Exception as e:
            print(f"Error handling connection: {e}")
        finally:
            conn.close()
            print("Connection closed.")

if __name__ == "__main__":
    data, gesture_prediction, inference_time = start_socket_server()
    print("\nFinal DataFrame:")
    print(data)
    print(f"\nCollected {len(data)} data points")
    print('\n')
    print(f"Gesture Inference: {gesture_prediction}")
    print(f"Inference took {inference_time:.3f} seconds")