## Minimal scipt to send and receive data from Hololens with IP's and PORT specified both here and in c# script (UDPComm.cs)
import socket
import struct

if __name__ == '__main__':
    UDP_IP = ""  # No IP specified, as we receive from any IP address (that's on the same subnet, 192.1.168.xxx)
    UDP_PORT = 9995  # Same port as we specified in UDPComm.cs

    sock = socket.socket(socket.AF_INET, # Internet
                         socket.SOCK_DGRAM) # UDP
    sock.bind((UDP_IP, UDP_PORT))

    while True:

        # data, addr = sock.recvfrom(1024)  # buffr size is 1024 bytes
        # Unpacks two floats from data : angle and angular velocity
        # print(data)
        # sock.sendto(bytes("Hello Holo!",'utf-8'), ("192.168.1.139", 9050))
        sock.sendto(bytes("-1.5",'utf-8'), ("127.0.0.1", 9050))
        