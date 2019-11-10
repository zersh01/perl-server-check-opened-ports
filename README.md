# perl-server-check-opened-ports
2 perl packages: 

1. use Net::Server and nc for check ports
2. use Net::Server and IO::Socket::PortState for check ports

# Usage:

Edit /etc/ckeckserver.cfg to configure server

Run on server bin/check_ports_server.pl

Connect from client (telnet or nc):

Enter command: 
 port - Checks one or few specified port. Use space separator.
 scan - Checks default ports: 25,110,80,443 3306 5666.
 exit/quit - close connection


