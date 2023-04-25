## linux-vm-diagnostics
Bash script to pull some diagnostic information from Linux VMs for troubleshooting and compress for sharing - optionally uploads to workspace with `azcopy`.

![screen](https://imgur.com/kPfTVKD.png)

### Usage 
- Curl, verify the script contents and run:
```
curl https://raw.githubusercontent.com/jameswylde/linux-vm-diagnostics/main/diag.sh > diag.sh
sudo bash diag.sh
```

_or_

- YOLO 
```
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/jameswylde/linux-vm-diagnostics/main/diag.sh)"
```

Collects:
- system info
- /var/log in full
- iostat over 5min
- sar over 5min
- top for CPU and mem over 5min

Optionally uploads to Azure workspace with SASURI.
