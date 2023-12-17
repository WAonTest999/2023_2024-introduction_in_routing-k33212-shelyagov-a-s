/ip address
add address=192.168.3.1/24 interface=ether2 network=192.168.3.0
add address=192.168.11.2/24 interface=ether3 network=192.168.11.0
add address=192.168.13.1/24 interface=ether4 network=192.168.13.0

/ip pool
add name=dhcp_pool0 ranges=192.168.3.2-192.168.3.254

/ip dhcp-server
add address-pool=dhcp_pool0 disabled=no interface=ether2 name=dhcp1




/ip dhcp-server option
add code=121 name=BRL121 value=0x10C0A8C0A80301

/ip dhcp-server network
add address=192.168.3.0/24 dhcp-option=BRL121 gateway=192.168.3.1








/ip route
add distance=1 dst-address=192.168.1.0/24 gateway=192.168.11.1
add distance=1 dst-address=192.168.2.0/24 gateway=192.168.13.2

