/interface bridge
add name=loopback


/routing ospf instance
set [ find default=yes ] router-id=192.168.100.11 

/ip address
add address=192.168.11.1/24 interface=ether2 network=192.168.11.0
add address=192.168.12.2/24 interface=ether3 network=192.168.12.0
add address=192.168.16.2/24  interface=ether4 network=192.168.16.0
add address=192.168.100.11 interface=loopback network=192.168.100.11 

/mpls ldp
set enabled=yes transport-address=192.168.100.11 

/mpls ldp interface
add interface=ether2
add interface=ether3
add interface=ether4

/routing ospf network
add area=backbone
