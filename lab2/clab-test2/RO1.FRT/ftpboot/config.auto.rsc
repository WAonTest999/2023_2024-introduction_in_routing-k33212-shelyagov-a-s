/ip address
add address=192.168.2.1/24 interface=ether2 network=192.168.2.0
add address=192.168.13.2/24 interface=ether3 network=192.168.13.0
add address=192.168.12.1/24 interface=ether4 network=192.168.12.0

/ip pool
add name=dhcp_pool0 ranges=192.168.2.2-192.168.2.254

/ip dhcp-server
add address-pool=dhcp_pool0 disabled=no interface=ether2 name=dhcp1

/ip dhcp-server option
add code=121 name=FRT121 value=0x10C0A8C0A80201

/ip dhcp-server network
add address=192.168.2.0/24 dhcp-option=FRT121 gateway=192.168.2.1

/ip route
add distance=1 dst-address=192.168.1.0/24 gateway=192.168.12.2
add distance=1 dst-address=192.168.3.0/24 gateway=192.168.13.1

