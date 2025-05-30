import socket,  struct, os
from helper import *
import numpy as np
import pandas as pd
import json

HOST = '127.0.0.1'  # Localhost
PORT = 65432        # Port to listen on

def send_message(sock, message):
    # Pack the message length and the message itself
    message_bytes = message.encode('utf-8')
    message_length = struct.pack('!I', len(message_bytes))
    sock.sendall(message_length + message_bytes)

def receive_message(sock):
    # First, receive the length of the message
    length_bytes = sock.recv(4)
    if not length_bytes:
        return None
    message_length = struct.unpack('!Q', length_bytes)[0]
    
    # Now receive the actual message
    message_bytes = sock.recv(message_length)
    return message_bytes.decode('utf-8')


def extract_features(signal):
    # Placeholder for feature extraction logic
    # This function should return a dictionary of features
    return {
        "std": std(signal),
        "energy": energy(signal),
        "max_val": max_val(signal),
        "mean": mean(signal),
        "min_max_range": min_max_range(signal),
        "min_val": min_val(signal),
        "median_above_mean": median_above_mean(signal),
        "interquartile_range": interquartile_range(signal),
        "skewness": skewness(signal),
        **psd_features(signal)
    }


test_path = os.path.join('/Users/mylesgould/Downloads/project/data/rotate_next/csv')

test_file = os.listdir(test_path)[0]
df = pd.read_csv(os.path.join(test_path, test_file))

raw_data_types = ['accel_x', 'accel_y', 'accel_z', 'rotation_x', 'rotation_y', 'rotation_z', 'roll', ' pitch', 'yaw']


features = []
for raw_data in raw_data_types:
    signal = df[raw_data].values

    features.extend(extract_features(signal))

features_bytes = json.dumps(features).encode('utf-8')

print(f"size of features: {len(features_bytes)}")
#     }   
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen(5)
    print(f"Server listening on {HOST}:{PORT}")
    conn, addr = s.accept()
    with conn:
        print('Connected by', addr)
        while True:

            data = conn.recv(1024)
            print(f"Received data: {data}\n")
            if not data:
                break
            conn.sendall(data)