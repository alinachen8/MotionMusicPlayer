import socket,  struct, os
from helper import *
import numpy as np
import pandas as pd
import json
import sys
import time

import threading


HOST = '127.0.0.1'  # Localhost
PORT = 65432        # Port to listen on

msg = '''
{
  "timestamp": 13.42,
  "accel": { "x": 0.11, "y": -0.23, "z": 0.98 },
  "gyro": { "x": 0.05, "y": 0.02, "z": 0.01 },
  "attitude": { "pitch": 1.32, "roll": 0.44, "yaw": 2.10 }
}
'''
print(len(msg.encode('utf-8')))

# sys.exit(0)

# def send_message(sock, message):
#     # Pack the message length and the message itself
#     message_bytes = message.encode('utf-8')
#     message_length = struct.pack('!I', len(message_bytes))
#     sock.sendall(message_length + message_bytes)

# def receive_message(sock):
#     # First, receive the length of the message
#     length_bytes = sock.recv(4)
#     if not length_bytes:
#         return None
#     message_length = struct.unpack('!Q', length_bytes)[0]
    
#     # Now receive the actual message
#     message_bytes = sock.recv(message_length)
#     return message_bytes.decode('utf-8')

    # return {
    #     "std": std(feature),
    #     "energy": energy(feature),
    #     "max_val": max_val(feature),
    #     "mean": mean(feature),
    #     "min_max_range": min_max_range(feature),
    #     "min_val": min_val(feature),
    #     "median_above_mean": median_above_mean(feature),
    #     "interquartile_range": interquartile_range(feature),
    #     "skewness": skewness(feature),
    #     **psd_features(feature)
    # }

def extract_features(feature):

    ''''Extracts various statistical features from a given signal feature.

    Args:
        feature (list or np.ndarray): The signal feature from which to extract features.

    Returns:
        list: A list of extracted features including standard deviation, energy, max value, mean, min-max range, min value,
            median above mean, interquartile range, skewness, and power spectral density features.
    '''

    return [
        std(feature),
        energy(feature),
        max_val(feature),
        mean(feature),
        min_max_range(feature),
        min_val(feature),
        median_above_mean(feature),
        interquartile_range(feature),
        skewness(feature),
        *psd_features(feature).values()
    ]

def full_feature_extraction(signal_features):

    '''Extracts features from a dictionary of signal features.
    Args:
        signal_features (dict): A dictionary where keys are feature names and values are lists or arrays of signal data.
    Returns:
        list: A list of all extracted features from all signal features.
    '''

    full_features = []

    for feature in signal_features:
        full_features.extend(extract_features(signal_features[feature]))

    return full_features


def model_predict(features):

    # Placeholder for model prediction logic
    # This function should return the prediction based on the features
    print(f"Received features for prediction: {features}")
    # Simulate a prediction
    return "predicted_label"





## Define the raw data types that we expect to receive
raw_data_types = ['accel_x', 'accel_y', 'accel_z', 'rotation_x', 'rotation_y', 'rotation_z', 'roll', ' pitch', 'yaw']

# Initialize a dictionary to hold the data types and their corresponding lists
data_types_dict = { k: [] for k in raw_data_types }

#create a socket server that listens for incoming connections
# and processes the incoming data
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:

    # Bind the socket to the host and port
    s.bind((HOST, PORT))

    # Listen for incoming connections
    s.listen(5)
    print(f"Server listening on {HOST}:{PORT}")

    # Accept a connection
    # This will block until a client connects
    conn, addr = s.accept()

    #with a connection established, we can now handle the client
    with conn:
        #print('Connected by', addr)
        # Wait for a request from the client


        while True:

            # Reset the start time for each new connection
            start_time = time.time()

            # Clear the data types dictionary for each new connection
            data_types_dict.clear()

            # Receive data from the client
            data = conn.recv(1024)

            def handle_client(conn, addr):
                print(f"Connected by {addr}")
                while True:
                    start_time = time.time()
                    data_types_dict.clear()
                    data = conn.recv(1024)
                    if data:
                        while time.time() - start_time < 2:
                            data = conn.recv(1024)
                            if not data:
                                continue
                            decoded_data = data.decode('utf-8')
                            decoded_json_data = json.loads(decoded_data)
                            for key in decoded_json_data:
                                if key in data_types_dict:
                                    data_types_dict[key].append(decoded_json_data[key])
                        full_features = full_feature_extraction(data_types_dict)
                        model_prediction = model_predict(full_features)
                        conn.sendall(model_prediction.encode('utf-8'))
                    else:
                        break
                conn.close()

            client_thread = threading.Thread(target=handle_client, args=(conn, addr), daemon=True)
            client_thread.start()

            # Later, you can check if the thread is alive:
            print(f"Client thread alive? {client_thread.is_alive()}")
            # Or wait for it to finish (if not daemon):
            
            stop_event = threading.Event()
       
            if data:
                while time.time() - start_time < 2:
                    data = conn.recv(1024)

                    if not data:
                        continue

                    decoded_data = data.decode('utf-8')
                    decoded_json_data = json.loads(decoded_data)

                    acceleration = decoded_json_data.get('accel', {})
                    rotation = decoded_json_data.get('gyro', {})
                    attitude = decoded_json_data.get('attitude', {})

                    for direction in acceleration:

                        key = f'accel_{direction}'
                        if key in data_types_dict:
                            data_types_dict[key].append(decoded_json_data[key])
                        else:
                            print(f"Key {key} not found in data_types_dict")
                    
                    for direction in rotation:
                        key = f'rotation_{direction}'

                        if key in data_types_dict:
                            data_types_dict[key].append(decoded_json_data[key])
                        else:
                            print(f"Key {key} not found in data_types_dict")
                    
                    for position in attitude:
                        if key in data_types_dict:
                            data_types_dict[position].append(decoded_json_data[position])
                        else:
                            print(f"Key {position} not found in data_types_dict")

                full_features = full_feature_extraction(data_types_dict)

                model_prediction = model_predict(full_features)

                conn.sendall(model_prediction.encode('utf-8'))

            client_thread.join()
                



            

            
            



        # while data:

        #     #print(f"Received data: {data}\n")
        #     # If you want to process the received data, you can do so here
        #     # For now, we just print it
        #     # data = receive_message(conn)
        #     # if not data:
        #     #     break
        # #print(f"Received data: {data}\n")

        
        # if data:
        #     # Send features as JSON string
        #     conn.sendall(features_bytes)
