/interface bridge
add name=EoMPLS_bridge
add name=loopback

/interface vpls
add cisco-style=yes cisco-style-id=100 disabled=no l2mtu=1500 mac-address=02:63:6E:00:C0:75 name=EoMPLS remote-peer=192.168.100.21

/routing ospf instance
set [ find default=yes ] router-id=192.168.100.22

/interface bridge port
add bridge=EoMPLS_bridge interface=ether4
add bridge=EoMPLS_bridge interface=EoMPLS

/ip address
add address=192.168.12.1/24 interface=ether2 network=192.168.12.0
add address=192.168.13.2/24 interface=ether3 network=192.168.13.0
add address=192.168.100.22 interface=loopback network=192.168.100.22

/mpls ldp
set enabled=yes transport-address=192.168.100.22

/mpls ldp interface
add interface=ether2
add interface=ether3

/routing ospf network
add area=backbone
