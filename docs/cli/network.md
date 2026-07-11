# Network

## Назначение

Диагностика IP, Wi-Fi, DNS, маршрутов, пропускной способности и сетевых сервисов.

## ip

```bash
ip addr
ip route
ip link
ip neigh
```

Проверяйте: есть ли IP, default route, active interface.

## NetworkManager / nmcli

```bash
nmcli device status
nmcli connection show
nmcli radio wifi on
nmcli device wifi list
nmcli device wifi connect SSID --ask
sudo systemctl restart NetworkManager
```

## dig

```bash
dig example.com A
dig example.com AAAA
dig example.com MX
dig example.com TXT
dig @1.1.1.1 example.com +short
```

## mtr

```bash
mtr example.com
mtr -rw example.com
```

Interactive показывает packet loss/latency, report mode удобен для сохранения.

## iperf3

Server:

```bash
iperf3 -s
```

Client:

```bash
iperf3 -c SERVER_IP
iperf3 -c SERVER_IP -R
```

## tcpdump

```bash
sudo tcpdump -i any
sudo tcpdump -i any host 1.1.1.1
sudo tcpdump -i any port 53
sudo tcpdump -i any udp port 53
sudo tcpdump -i any -w capture.pcap
```

Safety: capture может содержать приватные адреса, DNS-запросы, токены в незашифрованном трафике.

## nmap

Сканируйте только свои сети или с разрешения:

```bash
nmap -sn 192.168.1.0/24
nmap 192.168.1.1
nmap -sV 192.168.1.1
```

## Troubleshooting

Нет IP:

```bash
nmcli device status
sudo systemctl restart NetworkManager
```

DNS не работает:

```bash
ping -c 3 1.1.1.1
dig @1.1.1.1 example.com
resolvectl status
```

Wi-Fi есть, интернета нет:

```bash
ip route
ping -c 3 $(ip route | awk '/default/ {print $3; exit}')
```

VPN мешает: проверьте routes, DNS и активные connections.

## Cheatsheet

```bash
ip addr
ip route
nmcli device status
dig example.com +short
mtr -rw example.com
iperf3 -c host
sudo tcpdump -i any port 53
nmap -sn 192.168.1.0/24
```
