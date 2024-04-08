import socket

# Function to get the current IP address of the server
def get_ip_address():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # Doesn't even have to be reachable
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

# Define control functions here
def fr():
    print("Moving forward")
    # Add movement code here

def bk():
    print("Moving backward")
    # Add movement code here

def ri():
    print("Turning right")
    # Add movement code here

def le():
    print("Turning left")
    # Add movement code here

def st():
    print("Stopping")
    # Add stop code here

def process_command(command):
    if command == 'F':
        fr()
    elif command == 'B':
        bk()
    elif command == 'R':
        ri()
    elif command == 'L':
        le()
    elif command == 'S':
        st()
    else:
        print("Unknown command")

def main():
    host = ''  # Listen on all available interfaces
    port = 80  # Port number

    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind((host, port))
    server_socket.listen(1)

    # Get the current IP address and print it
    ip_address = get_ip_address()
    print(f"Listening on {ip_address}:{port}...")

    while True:
        client_socket, address = server_socket.accept()
        print(f"Connection from {address} has been established!")

        try:
            while True:
                command = client_socket.recv(1024).decode('utf-8').strip()
                if not command:
                    print("Connection closed by the client.")
                    break
                print(f"Received command: {command}")
                process_command(command)
        except Exception as e:
            print(f"An error occurred: {e}")
        finally:
            client_socket.close()
            print("Ready for a new connection.")

if __name__ == '__main__':
    main()
