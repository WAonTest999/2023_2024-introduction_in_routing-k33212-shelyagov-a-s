/interface vlan
add name=bridge1.11 interface=ether2 vlan-id=11
add name=bridge1.12 interface=ether2 vlan-id=12

/ip pool
add name=pool11 ranges=192.168.11.2-192.168.11.254
add name=pool12 ranges=192.168.12.2-192.168.12.254

/ip dhcp-server
add address-pool=pool11 disabled=no interface=vlan11 name=server1
add address-pool=pool12 disabled=no interface=vlan12 name=server2

/ip address
add address=192.168.1/24 interface=vlan11 network=192.168.11.0
add address=192.168.1/24 interface=vlan12 network=192.168.12.0
