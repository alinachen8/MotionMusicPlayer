import socket


#get it over a globsl network/ firewall/ 


#polling, what achitecture


#identify an object and know an unknown object


HOST = "localhost"  # Change to the server's IP address if needed

HOST = "127.0.0.1"
#HOST =  "192.168.1.100"

PORT = 65432

while True:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))
        s.sendall(b'Hello, server!')
        s.sendall(b' This is a test message.')
        data = s.recv(1024)


        print(f"Received from server: {data.decode()}")
