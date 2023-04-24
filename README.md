# linux-vm-diagnostics
Simple bash script to pull some diagnostic information from Linux VMs for troubleshooting and compress for sharing - optionally uploads to workspace with `azcopy`.

Either clone locally or execute via. `sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/jameswylde/linux-vm-diagnostics/main/diag.sh)"`

Collects:
- system info
- /var/log in full
- iostat over 5min
- sar over 5min
- top for CPU and mem over 5min
