# Hardware diagnostics

## Назначение

Диагностика железа ноутбука/ПК: PCI/USB, диски, температура, батарея, audio/media, brightness, power profile.

## Инвентаризация

```bash
sudo lshw -short
lspci
lsusb
lsblk
```

## Диски

```bash
sudo smartctl -a /dev/sda
sudo nvme list
sudo nvme smart-log /dev/nvme0
```

Сначала определите устройство через `lsblk`. Не запускайте destructive disk commands без понимания.

## Температура и питание

```bash
sensors
sudo powertop
upower -i $(upower -e | rg BAT | head -n1)
powerprofilesctl
powerprofilesctl set power-saver
powerprofilesctl set balanced
```

## Brightness/media/audio

```bash
brightnessctl
brightnessctl set 5%+
playerctl status
playerctl play-pause
pamixer --get-volume
pamixer -i 5
pamixer -t
```

## Bluetooth basics

```bash
systemctl status bluetooth
bluetoothctl
```

В системе включены `hardware.bluetooth` и `services.blueman`.

## Typical laptop diagnostics

```bash
upower -d
sensors
duf
journalctl -b -p err
systemctl --failed
```

## Troubleshooting

- Battery не видна: `upower -d`, `ls /sys/class/power_supply`.
- Disk errors: `journalctl -b | rg -i "nvme|ata|smart|error"`.
- Audio нет: `pamixer --get-volume`, `pavucontrol`, PipeWire logs.
- Brightness не работает: `brightnessctl -l`, permissions.

## Cheatsheet

```bash
sudo lshw -short
lspci
lsusb
lsblk
sensors
upower -d
brightnessctl
pamixer --get-volume
```
