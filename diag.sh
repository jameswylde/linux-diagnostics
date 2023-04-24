#!/bin/bash
time_eta=$(date '+%H:%M:%S' -d '+15 minutes')
echo -e "\e[35m\nCollecting system information and performance data for troubleshooting.\nDiagnostic collection should be finished $time_eta - this does not include time taken to upload the file to workspace if chosen.\n"

# Create a directory for diagnotics
diagnostics_dir="diagnostics-$(date '+%Y%m%d-%H%M%S')"
echo -e "\e[96m[1/8]\e[33m - Creating diagnostics directory: $(pwd)/$diagnostics_dir\n"
mkdir "$diagnostics_dir"

# Copy /var/log to diagnostics directory
echo -e "\e[96m[2/8]\e[33m - Copying /var/log: $diagnostics_dir/var/log/\n"
cp -r /var/log "$diagnostics_dir/var-log" &
wait %1

# Run iostat 300s
if ! command -v iostat &>/dev/null; then
      echo -e "iostat could not be found. Skipping. If iostat is required, install and rerun script"
fi
iostat_file="$diagnostics_dir/iostat-$(date '+%m%d%H%M%S')-$(date '+%Z')-$(hostname).log"
echo -e "\e[96m[3/8]\e[33m - Collecting iostat: $iostat_file\n"
iostat -dxmyt 1 30 >"$iostat_file" &
wait %1

# Run sar 300s
sar_file="$diagnostics_dir/sar-$(date '+%m%d%H%M%S')-$(date '+%Z')-$(hostname).log"
echo -e "\e[96m[4/8]\e[33m - Collecting sar: $sar_file\n"
sar -A 1 30 >"$sar_file" &
wait %1

# Run top (CPU) 300s
top_cpu_file="$diagnostics_dir/top-cpu-$(date '+%m%d%H%M%S')-$(date '+%Z')-$(hostname).log"
echo -e "\e[96m[5/8]\e[33m - Collecting top CPU utilisation: $top_cpu_file\n"
top -b -d 1 -n 30 -o +%CPU | grep -A 15 average >"$top_cpu_file" &
wait %1

# Run top (memory) 300s
top_mem_file="$diagnostics_dir/top-mem-$(date '+%m%d%H%M%S')-$(date '+%Z')-$(hostname).log"
echo -e "\e[96m[6/8]\e[33m - Collecting top memory utilisation: $top_mem_file\n"
top -b -d 1 -n 30 -o +%MEM | grep -A 15 average >"$top_mem_file" &
wait %1

# Grab system info
system_file="$diagnostics_dir/system-info-$(date '+%m%d%H%M%S')-$(date '+%Z')-$(hostname).log"
echo -e "\e[96m[7/8]\e[33m - Getting system info: $system_file\n"
cat /etc/*-release >"$diagnostics_dir/*-release-$(date '+%m%d%H%M%S')-$(date '+%Z')-$(hostname).txt"
uname -a >"$diagnostics_dir/uname-$(date '+%m%d%H%M%S')-$(date '+%Z')-$(hostname).txt"
df -h >"$diagnostics_dir/df-$(date '+%m%d%H%M%S')-$(date '+%Z')-$(hostname).txt"
free -m >"$diagnostics_dir/free-$(date '+%m%d%H%M%S')-$(date '+%Z')-$(hostname).txt"
ps -ef >"$diagnostics_dir/ps-$(date '+%m%d%H%M%S')-$(date '+%Z')-$(hostname).txt"

# Tar archive and cleanup
diagnostics_archive="$diagnostics_dir.tar.gz"
echo -e "\e[96m[8/8]\e[33m - Creating diagnostics archive: $diagnostics_archive\n"
tar -czf "$diagnostics_archive" "$diagnostics_dir"
rm -rf "$diagnostics_dir"

echo -e "\e[32mDiagnostics complete. The diagnostics archive can be found in:\e[33m\n$(pwd)/$diagnostics_archive\e[35m\n"

# Upload to SASURI using az copy
echo -n -e "\e[32mUpload $diagnostics_archive to workspace (azcopy) - y/n:\e[35m "
read upload_choice

if [[ $upload_choice =~ ^[Yy]$ ]]; then
      echo -n -e "\e[32m\nSASURI: \e[35m"
      read sas_uri
      echo -e "\n\e[96mazcopy copy "$diagnostics_archive" "$sas_uri"\n\e[33m"
      azcopy copy "$diagnostics_archive" "$sas_uri"
fi

