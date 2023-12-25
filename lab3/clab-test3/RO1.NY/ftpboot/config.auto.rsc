/interface bridge
add name=EoMPLS_bridge
add name=loopback

/interface vpls
add cisco-style=yes cisco-style-id=100 disabled=no l2mtu=1500 mac-address=02:90:6A:B9:96:C8 name=EoMPLS remote-peer=192.168.100.22

/routing ospf instance
set [ find default=yes ] router-id=192.168.100.21

/interface bridge port
add bridge=EoMPLS_bridge interface=ether2
add bridge=EoMPLS_bridge interface=EoMPLS

/ip address
add address=192.168.15.1/24 interface=ether2 network=192.168.15.0
add address=192.168.10.2/24 interface=ether3 network=192.168.10.0
add address=192.168.100.21 interface=loopback network=192.168.100.21

/mpls ldp
set enabled=yes transport-address=192.168.100.21

/mpls ldp interface
add interface=ether3
add interface=ether4

/routing ospf network
add area=backbone
