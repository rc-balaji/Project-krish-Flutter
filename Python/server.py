import socket

def get_ip_address():
    # Attempt to connect to an Internet host in order to determine the local machine's IP address
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # This does not actually establish a connection
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = "127.0.0.1"  # Default to localhost if unable to determine
    finally:
        s.close()
    return ip

def start_server(port=12345):
    host = get_ip_address()  # Use the actual IP address here
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind((host, port))
    server_socket.listen()

    print(f"Listening for connections on {host}:{port}...")

    while True:
        print("Waiting for a new connection...")
        client_socket, address = server_socket.accept()
        print(f"Connection from {address} has been established.")

        while True:
            message = client_socket.recv(1024).decode('utf-8')
            if message:
                print(f"Received: {message}")
            else:
                print("No more messages. Closing connection.")
                break

        client_socket.close()
        print("Ready to accept a new connection.")

    # This part of the code will not be reached in this setup because the server is designed to run indefinitely.
    # If you add a condition to break out of the loop, remember to close the server socket as well.
    # server_socket.close()

if __name__ == "__main__":
    start_server()
