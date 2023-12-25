/interface bridge
add name=loopback


/routing ospf instance
set [ find default=yes ] router-id=192.168.100.13 

/ip address
add address=192.168.13.1/24 interface=ether2 network=192.168.13.0
add address=192.168.14.2/24 interface=ether3 network=192.168.14.0
add address=192.168.100.13 interface=loopback network=192.168.100.13

/mpls ldp
set enabled=yes transport-address=192.168.100.13

/mpls ldp interface
add interface=ether2
add interface=ether3

/routing ospf network
add area=backbone
