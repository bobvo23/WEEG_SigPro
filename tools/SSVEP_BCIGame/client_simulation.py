"""
    Send message to the sever and recieve data back
    Acts like a client

    Python version: 2.5
    Dependencies: sever.py
"""

import socket
import sys

# Create a TCP/IP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connect the socket to the port where there server is listening
server_address = ('localhost', 55000)   # The address should match server's
print >> sys.stderr, 'connecting to %s port %s' % server_address
sock.connect(server_address)

"""
    After the connection is established, data can be sent through the socket
    with sendall() and received wit recv(), just as in the server
"""
while True:
    # i = raw_input('Enter command: ')
    # sock.sendall(i)

    # if i == 'q': break
    # Send data
    for i in range(0, 100):
        sock.sendall('1')
    for i in range(0, 100):
        sock.sendall('2')
    for i in range(0, 100):
        sock.sendall('3')
    for i in range(0, 100):
        sock.sendall('4')

print >> sys.stderr, 'closing socket'
sock.close()
    
