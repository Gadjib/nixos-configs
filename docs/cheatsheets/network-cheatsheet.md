# Network cheatsheet

## IP/routes

```bash
ip addr
ip route
ip link
ip neigh
```

## NetworkManager

```bash
nmcli device status
nmcli connection show
nmcli radio wifi on
nmcli device wifi list
nmcli device wifi connect SSID --ask
sudo systemctl restart NetworkManager
```

## DNS

```bash
dig example.com A
dig example.com AAAA
dig example.com MX
dig example.com TXT
dig @1.1.1.1 example.com +short
```

## Path/performance

```bash
mtr example.com
mtr -rw example.com
iperf3 -s
iperf3 -c SERVER
iperf3 -c SERVER -R
```

## tcpdump

```bash
sudo tcpdump -i any
sudo tcpdump -i any host 1.1.1.1
sudo tcpdump -i any port 53
sudo tcpdump -i any -w capture.pcap
```

## nmap

```bash
nmap -sn 192.168.1.0/24
nmap 192.168.1.1
nmap -sV 192.168.1.1
```

Сканировать только свои сети или с разрешения.
