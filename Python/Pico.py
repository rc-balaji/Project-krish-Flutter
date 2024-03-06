import network
import socket
import utime

def wifi_connect(ssid, password):
    
    sta = network.WLAN(network.STA_IF)
    if not sta.isconnected():
        sta.active(True)
        # Set static IP, subnet mask, gateway, and DNS
        sta.ifconfig(('192.168.251.96', '255.255.255.0', '192.168.251.1', '8.8.8.8'))
        sta.connect(ssid, password)
        while not sta.isconnected():
            pass
    if sta.isconnected():
        draw_circle(fb, 30, 16, 13, 1)
        draw_circle(fb, 30, 18, 5, 1)
        display.blit(fb, 0, 0)
        display.show()
        draw_circle(fb, 90, 16, 13, 1)
        draw_circle(fb, 90, 18, 5, 1)
        display.blit(fb, 0, 0)
        display.show()

        # Play a welcome audio or perform an action
        player = wavePlayer()
        player.play('/Audio/Name.wav')
        servo_hello()
        utime.sleep(3)
    print('Connected to WiFi with static IP. Network config:', sta.ifconfig())
def start_server():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(('', 80))
    s.listen(5)
    print('Server listening on port 80')
    
    while True:
        conn, addr = s.accept()
        print(f'Connection from {addr}')
        
        try:
            while True:
                request = conn.recv(1024).decode("utf-8").strip()
                
                if not request:
                    break

                if request.startswith("GET"):
                    response = "HTTP/1.1 200 OK\n\nHello, World!"
                    conn.send(response.encode('utf-8'))
                else:
                    process_command(request)

        except socket.timeout:
            print("Connection timed out.")
        except Exception as e:
            print(f"An error occurred: {e}")
        finally:
            conn.close()
            print("Connection closed. Ready for a new connection.")

def process_command(command):
    print("Processing command:", command)
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

def main():
    ssid = 'AB7'
    password = '07070707'
    try:
        wifi_connect(ssid, password)
        start_server()
    except Exception as e:
        print(f"Failed to connect or start server: {e}")
        # Try to establish AP mode if WiFi connection fails
        ap_mode('FallbackSSID', 'FallbackPassword')

def ap_mode(ssid, password):
    ap = network.WLAN(network.AP_IF)
    ap.config(essid=ssid, password=password)
    ap.active(True)
    while not ap.active():
        pass
    print('AP Mode Active. Connect to IP:', ap.ifconfig()[0])
    start_server()

main()
