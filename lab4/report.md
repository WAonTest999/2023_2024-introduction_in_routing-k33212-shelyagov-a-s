University: [ITMO University](https://itmo.ru/ru/)  
Faculty: [FICT](https://fict.itmo.ru)  
Course: [Introduction in routing](https://github.com/itmo-ict-faculty/introduction-in-routing)  
Year: 2023/2024  
Group: K33212  
Author: Shelyagov Aleksei Sergeevich       
Lab: Lab4 
Date of create: 25.12.2023  
Date of finished: 25.12.2023 

## Лабораторная работ №4 "Эмуляция распределенной корпоративной сети связи, настройка статической маршрутизации между филиалами"

## Цель работы
Изучить протоколы BGP, MPLS и правила организации L3VPN и VPLS.

## Ход работы   

Развернем сеть в ContainerLab. Перед запуском сети были созданы контейнеры ```ubuntu:latest```(последняя версия Ubuntu) и ```vrnetlab/vr-routeros:6.47.9```(RouterOS-контейнер)
Также, пропишем config-файлы для Mikrotik'ов и скрипты, настрaивающие Ubunt'ы после запуска:

### Файл, конфигурирующий сеть
```
name: test4

mgmt:
  ipv4-subnet: 172.20.20.0/24


topology:
  nodes:
    RO1.MSK:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 172.20.20.11
      startup-config: R01.LBN.cfg
    RO1.SVL:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 172.20.20.12
      startup-config: R01.SVL.cfg
    RO1.LND:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 172.20.20.13
      startup-config: R01.LND.cfg
    RO1.NY:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 172.20.20.14
      startup-config: R01.NY.cfg
    RO1.HKI:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 172.20.20.15
      startup-config: R01.HKI.cfg
    RO1.SPB:
      kind: vr-ros
      image: vrnetlab/vr-routeros:6.47.9
      mgmt-ipv4: 172.20.20.16
      startup-config: R01.SPB.cfg
      
      
    PC1:
      kind: linux
      image: ubuntu:latest
      mgmt-ipv4: 172.20.20.21
      binds:
        - setup_ubuntu.sh:/tmp/setup.sh
      exec:
        - bash /tmp/setup.sh  
    PC2:
      kind: linux
      image: ubuntu:latest
      mgmt-ipv4: 172.20.20.22
      binds:
        - setup_ubuntu.sh:/tmp/setup.sh
      exec:
        - bash /tmp/setup.sh  
    PC3:
      kind: linux
      image: ubuntu:latest
      mgmt-ipv4: 172.20.20.23
      binds:
        - setup_ubuntu.sh:/tmp/setup.sh
      exec:
        - bash /tmp/setup.sh

    
  links:
    - endpoints: ["RO1.SPB:eth1", "PC1:eth1"]
    - endpoints: ["RO1.SPB:eth2", "RO1.HKI:eth3"]
    - endpoints: ["RO1.NY:eth1", "PC2:eth1"]
    - endpoints: ["RO1.NY:eth2", "RO1.LND:eth3"]
    - endpoints: ["RO1.SVL:eth1", "PC3:eth1"]
    - endpoints: ["RO1.SVL:eth2", "RO1.LBN:eth3"]
    - endpoints: ["RO1.LND:eth1", "RO1.HKI:eth1"]
    - endpoints: ["RO1.LND:eth2", "RO1.LBN:eth1"]
    - endpoints: ["RO1.HKI:eth2", "RO1.LBN:eth2"]
```


### Полученная топология сети

<img src="./img/schema4.png" width=900>

### Скрипт для настройкки Ubuntu
(Также, заранее сгенерировал ssh-ключи и поместил публчный в этот скрипт)
```
#!/bin/bash
mkdir /root/.ssh
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAO8lVSwDTQ11hg2FWAQmCMPI1yLzVLdYxkE0n4QvyIq' >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

apt-get update > /dev/null

DEBIAN_FRONTEND=noninteractive apt-get install -y iproute2 iputils-ping sudo net-tools isc-dhcp-client openssh-server mtr > /dev/null

echo "ubuntu" | sudo adduser "ubuntu"
echo  "ubuntu:ubuntu" | sudo chpasswd

usermod -aG sudo "ubuntu"
service ssh start

suod dhclient eth1
```
### Config-файл для роутера R01.HKI:
```
/interface bridge
add name=loopback

/routing bgp instance
set default router-id=192.168.100.3

/routing ospf instance
set [ find default=yes ] router-id=192.168.100.3

/ip address
add address=192.168.11.1/24 interface=ether2 network=1192.168.11.0
add address=192.168.14.2/24 interface=ether3 network=192.168.14.0
add address=192.168.12.3/24 interface=ether4 network=192.168.12.0
add address=192.168.100.3 interface=loopback network=192.168.100.3

/mpls ldp
set enabled=yes

/mpls ldp interface
add interface=ether2
add interface=ether3
add interface=ether4

/routing bgp peer
add address-families=ip,l2vpn,l2vpn-cisco,vpnv4 name=peer1 remote-address=192.168.100.2 remote-as=65530 route-reflect=yes update-source=loopback
add address-families=ip,l2vpn,l2vpn-cisco,vpnv4 name=peer2 remote-address=192.168.100.5 remote-as=65530 route-reflect=yes update-source=loopback
add address-families=ip,l2vpn,l2vpn-cisco,vpnv4 name=peer3 remote-address=192.168.100.4 remote-as=65530 update-source=loopback

/routing ospf network
add area=backbone
```
### Config-файл для роутера R01.LBN:
```
/interface bridge
add name=loopback

/routing bgp instance
set default router-id=192.168.100.5

/routing ospf instance
set [ find default=yes ] router-id=192.168.100.5

/ip address
add address=192.168.14.1/24 interface=ether2 network=192.168.14.0
add address=192.168.13.2/24 interface=ether3 network=192.168.13.0
add address=192.168.15.3/24 interface=ether4 network=192.168.15.0
add address=192.168.100.5 interface=loopback network=192.168.100.5

/mpls ldp
set enabled=yes

/mpls ldp interface
add interface=ether2
add interface=ether3
add interface=ether4

/routing bgp peer
add address-families=ip,l2vpn,l2vpn-cisco,vpnv4 name=peer1 remote-address=192.168.100.2 remote-as=65530 route-reflect=yes update-source=loopback
add address-families=ip,l2vpn,l2vpn-cisco,vpnv4 name=peer2 remote-address=192.168.100.3 remote-as=65530 route-reflect=yes update-source=loopback
add address-families=ip,l2vpn,l2vpn-cisco,vpnv4 name=peer3 remote-address=192.168.100.6 remote-as=65530 update-source=loopback

/routing ospf network
add area=backbone
```

### Config-файл для роутера R01.LND:
```
/interface bridge
add name=loopback


/routing bgp instance
set default router-id=192.168.100.2

/routing ospf instance
set [ find default=yes ] router-id=192.168.100.2

/ip address
add address=2.2.2.2 interface=loopback network=192.168.100.2
add address=192.168.13.1/24 interface=ether2 network=192.168.13.0
add address=192.168.11.2/24 interface=ether3 network=192.168.11.0
add address=192.168.10.3/24 interface=ether4 network=192.168.10.0

/mpls ldp
set enabled=yes

/mpls ldp interface
add interface=ether2
add interface=ether3
add interface=ether4

/routing bgp peer
add address-families=ip,l2vpn,l2vpn-cisco,vpnv4 name=peer1 remote-address=192.168.100.1 remote-as=65530 update-source=loopback
add address-families=ip,l2vpn,l2vpn-cisco,vpnv4 name=peer2 remote-address=192.168.100.3 remote-as=65530 route-reflect=yes update-source=loopback
add address-families=ip,l2vpn,l2vpn-cisco,vpnv4 name=peer3 remote-address=192.168.100.5 remote-as=65530 route-reflect=yes update-source=loopback

/routing ospf network
add area=backbone
```
### Config-файл для роутера R01.SVL:
```
/interface bridge
add name=loopback


/routing bgp instance
set default router-id=192.168.100.6

/routing ospf instance
set [ find default=yes ] router-id=192.168.100.6

/ip address
add address=192.168.23.1/24 interface=ether2 network=192.168.23.0
add address=192.168.15.2/24 interface=ether3 network=192.168.15.0
add address=192.168.100.6 interface=loopback network=192.168.100.6

/ip route vrf
add export-route-targets=65530:10 import-route-targets=65530:10 interfaces=ether2 route-distinguisher=65530:10 routing-mark=VRF_TABLE

/ip dhcp-client
add disabled=no interface=ether1

/mpls ldp
set enabled=yes

/mpls ldp interface
add interface=ether3

/routing bgp instance vrf
add redistribute-connected=yes routing-mark=VRF_TABLE

/routing bgp peer
add address-families=ip,l2vpn,l2vpn-cisco,vpnv4 name=peer1 remote-address=192.168.100.5 remote-as=65530 update-source=loopback

/routing ospf network
add area=backbone
```

### Config-файл для роутера R01.NY:
```
/interface bridge
add name=loopback

/routing bgp instance
set default redistribute-connected=yes router-id=192.168.100.1

/routing ospf instance
set [ find default=yes ] router-id=192.168.100.1

/ip address
add address=192.168.22.1/24 interface=ether2 network=192.168.22.0
add address=192.168.10.2/24 interface=ether3 network=192.168.10.0
add address=192.168.100.1 interface=loopback network=192.168.100.1

/ip route vrf
add export-route-targets=65530:10 import-route-targets=65530:10 interfaces=ether2 route-distinguisher=65530:10 routing-mark=VRF_TABLE

/routing bgp instance vrf
add redistribute-connected=yes routing-mark=VRF_TABLE

/mpls ldp
set enabled=yes

/mpls ldp interface
add interface=ether3

/routing bgp peer
add address-families=ip,l2vpn,l2vpn-cisco,vpnv4 name=peer1 remote-address=192.168.100.2 remote-as=65530 update-source=loopback

/routing ospf network
add area=backbone
```

### Config-файл для роутера R01.SPB:
```
/interface bridge
add name=loopback

/routing bgp instance
set default router-id=192.168.100.4

/routing ospf instance
set [ find default=yes ] router-id=192.168.100.4


/ip address
add address=192.168.21.1/24 interface=ether2 network=192.168.21.0
add address=192.168.12.2/24 interface=ether3 network=192.168.12.0
add address=192.168.100.4 interface=loopback network=192.168.100.4

/ip route vrf
add export-route-targets=65530:10 import-route-targets=65530:10 interfaces=ether2 route-distinguisher=65530:10 routing-mark=VRF_TABLE

/mpls ldp
set enabled=yes

/mpls ldp interface
add interface=ether3

/routing bgp instance vrf
add redistribute-connected=yes routing-mark=VRF_TABLE

/routing bgp peer
add address-families=ip,l2vpn,l2vpn-cisco,vpnv4 name=peer1 remote-address=192.168.100.3 remote-as=65530 update-source=loopback

/routing ospf network
add area=backbone
```



## Часть 2
В результате выполненя первой части лабораторной работы на устройствах был разобран VRF и настроен VPLS. Для этого на каждом конечном роутере были добавлены соответствующие vpls-интерфейсы, а также bridge vpls.


### Config-файл для роутера R01.SVL:
```
/interface bridge
add name=loopback
add name=VPLS

/interface vpls
add disabled=no l2mtu=1500 mac-address=93:87:8A:9C:ED:C9 name=vpls1 remote-peer=192.168.100.1 vpls-id=10:0
add disabled=no l2mtu=1500 mac-address=64:10:C5:A3:A5:6B name=vpls2 remote-peer=192.168.100.4 vpls-id=10:0

/routing bgp instance
set default router-id=192.168.100.6

/routing ospf instance
set [ find default=yes ] router-id=192.168.100.6

/interface bridge port
add bridge=VPLS interface=vpls1
add bridge=VPLS interface=vpls2
add bridge=VPLS interface=ether2

/ip address
add address=192.168.23.1/24 interface=ether2 network=192.168.23.0
add address=192.168.15.2/24 interface=ether3 network=192.168.15.0
add address=192.168.100.6 interface=loopback network=192.168.100.6

/ip dhcp-client
add disabled=no interface=ether1

/mpls ldp
set enabled=yes

/mpls ldp interface
add interface=ether3

/routing bgp peer
add address-families=ip,l2vpn,l2vpn-cisco,vpnv4 name=peer1 remote-address=192.168.100.5 remote-as=65530 update-source=loopback

/routing ospf network
add area=backbone
```

### Config-файл для роутера R01.NY:
```
/interface bridge
add name=loopback
add name=VPLS

/interface vpls
add disabled=no l2mtu=1500 mac-address=64:10:C5:A3:A5:6B name=vpls1 remote-peer=192.168.100.4 vpls-id=10:0
add disabled=no l2mtu=1500 mac-address=9C:6A:79:D2:A8:4A name=vpls2 remote-peer=192.168.100.6 vpls-id=10:0

/routing bgp instance
set default redistribute-connected=yes router-id=192.168.100.1

/routing ospf instance
set [ find default=yes ] router-id=192.168.100.1

/interface bridge port
add bridge=VPLS interface=vpls1
add bridge=VPLS interface=vpls2
add bridge=VPLS interface=ether2

/ip address
add address=192.168.22.1/24 interface=ether2 network=192.168.22.0
add address=192.168.10.2/24 interface=ether3 network=192.168.10.0
add address=192.168.100.1 interface=loopback network=192.168.100.1

/mpls ldp
set enabled=yes

/mpls ldp interface
add interface=ether3

/routing bgp peer
add address-families=ip,l2vpn,l2vpn-cisco,vpnv4 name=peer1 remote-address=192.168.100.2 remote-as=65530 update-source=loopback

/routing ospf network
add area=backbone
```

### Config-файл для роутера R01.SPB:
```
/interface bridge
add name=loopback
add name=VPLS

/interface vpls
add disabled=no l2mtu=1500 mac-address=93:87:8A:9C:ED:C9 name=vpls1 remote-peer=192.168.100.1 vpls-id=10:0
add disabled=no l2mtu=1500 mac-address=9C:6A:79:D2:A8:4A name=vpls2 remote-peer=192.168.100.6 vpls-id=10:0

/routing bgp instance
set default router-id=192.168.100.4

/routing ospf instance
set [ find default=yes ] router-id=192.168.100.4

/interface bridge port
add bridge=VPLS interface=vpls1
add bridge=VPLS interface=vpls2
add bridge=VPLS interface=ether2

/ip address
add address=192.168.21.1/24 interface=ether2 network=192.168.21.0
add address=192.168.12.2/24 interface=ether3 network=192.168.12.0
add address=192.168.100.4 interface=loopback network=192.168.100.4

/ip dhcp-client
add disabled=no interface=ether1

/mpls ldp
set enabled=yes

/mpls ldp interface
add interface=ether3

/routing bgp peer
add address-families=ip,l2vpn,l2vpn-cisco,vpnv4 name=peer1 remote-address=192.168.100.3 remote-as=65530 update-source=loopback

/routing ospf network
add area=backbone
```

### Проверка правильности настройки:
В результате проверки можно убедиться, что все устройства соединены и функционируют в соответствии с заданием

<img src="./img/ping1.png" width=500>
<img src="./img/ping2.png" width=500>



## Вывод
В результате лабораторной работы удалось ознакомиться с принципами работы протоколов BGP и MPLS, а также с правилами организации L3VPN и VPLS.
