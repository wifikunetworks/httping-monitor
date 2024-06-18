#!/bin/bash

# Fungsi untuk menulis log saat status koneksi OFFLINE
write_offline_log() {
    echo "$(date +"%A %d %B %Y Pukul: %T") Status: OFFLINE $1" >> /etc/modem/log.txt
}

# Fungsi untuk menulis log saat status koneksi ONLINE
write_online_log() {
    echo "$(date +"%A %d %B %Y Pukul: %T") Status: ONLINE response time=$1 ms" >> /etc/modem/log.txt
}

# Fungsi untuk menunggu selama waktu yang ditentukan
wait_seconds() {
    local end_time=$(( $(date +%s) + $1 ))
    while [ $(date +%s) -lt $end_time ]; do
        sleep 1
    done
}

# Inisialisasi jumlah status offline berturut-turut
offline_count=0

# Interval waktu antara setiap pengecekan (detik)
check_interval=5

# Interval waktu antara penulisan log saat status koneksi OFFLINE (detik)
offline_log_interval=5

# Interval waktu antara penulisan log saat status koneksi ONLINE (detik)
online_log_interval=60

# Variabel untuk menentukan jumlah maksimum percobaan koneksi offline sebelum melakukan restart modem dan interface
max_retry=15

# Waktu awal untuk penulisan log saat status koneksi ONLINE
next_online_log_time=$(date +%s)

# URL yang akan di-httping untuk memeriksa koneksi
httping_target="1.1.1.1"  

# Loop utama
while true; do
    # Waktu awal untuk pengecekan
    start_time=$(date +%s)
    
    # Cek koneksi internet dengan httping ke URL yang ditentukan
    if httping -c 1 -t 1 $httping_target &> /dev/null; then
        # Jika httping berhasil (berarti koneksi online)
        offline_count=0
        if [ $(date +%s) -ge $next_online_log_time ]; then
            httping_result=$(httping -c 1 -t 1 $httping_target | grep 'time=' | awk -F 'time=' '{print $2}' | awk '{print $1}')
            write_online_log $httping_result
            next_online_log_time=$((next_online_log_time + online_log_interval))
        fi
    else
        # Jika httping gagal (berarti koneksi offline)
        ((offline_count++))
        write_offline_log "Failed $offline_count out of $max_retry"
        # Jika offline lebih dari jumlah maksimum percobaan
        if [ $offline_count -ge $max_retry ]; then
            write_offline_log "Failed $offline_count out of $max_retry > Action: Restart Modem"
            # Restart modem
            echo "at+cfun=1,1" > /dev/ttyACM2
            wait_seconds 10
            write_offline_log "Failed $offline_count out of $max_retry > Action: Restart Interface"
            # Restart interface modem
            ifdown mm && sleep 5 && ifup mm
            wait_seconds 10
            # Reset offline count
            offline_count=0
        fi
    fi
    
    # Waktu akhir untuk pengecekan
    end_time=$(date +%s)
    
    # Hitung sisa waktu sebelum melakukan pengecekan berikutnya
    remaining_time=$((check_interval - (end_time - start_time)))
    
    # Tunggu hingga waktunya untuk melakukan pengecekan berikutnya
    while [ $remaining_time -gt 0 ]; do
        sleep 1
        remaining_time=$((remaining_time - 1))
    done
done
