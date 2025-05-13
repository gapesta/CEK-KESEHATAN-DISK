#!/bin/bash
pth="\033[97m"
rst="\033[0m"
RED='\033[0;31m'

lsblk
lsblk -d -o name,rota,model
echo -e "${pth}Kalau ROTA = 1 → HDD

Kalau ROTA = 0 → SSD

Lalu, disk-nya akan muncul sebagai /dev/sdX.${rst}"
# Lokasi log
#LOG_FILE="/var/log/nvme-health.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
clear  
echo -e "${pth}Silakan pilih Disk Mana Yang Mau DIcek ?$rst"
echo -e ""
echo -e "     \e[1;32m1)\e[0m NVME"
echo -e "     \e[1;32m2)\e[0m SSD"
echo -e "     \e[1;32m3)\e[0m HDD"
echo -e " "
read -p "   Please select numbers 1-3 : " plh
echo ""
if [[ $plh == "1" ]]; then
    read -p "Masukkan nama device NVMe: " DEVICE

    # Cek SMART data NVMe
    NVME_INFO=$(nvme smart-log /dev/$DEVICE)
    sudo nvme smart-log /dev/$DEVICE
    # Ambil nilai penting
    PERCENT_USED=$(echo "$NVME_INFO" | grep "percentage_used" | awk '{print $3}' | tr -d '%')
    MEDIA_ERRORS=$(echo "$NVME_INFO" | grep "media_errors" | awk '{print $3}')
    TEMP=$(echo "$NVME_INFO" | grep -m1 "temperature" | awk '{print $3}')

    # Simpan log
    #echo "$DATE - Used: ${PERCENT_USED}%, Media Errors: $MEDIA_ERRORS, Temp: ${TEMP}C" >> "$LOG_FILE"
    echo -e "\e[1;32m2)\e[0m $DATE - Used: ${PERCENT_USED}%, Media Errors: $MEDIA_ERRORS, Temp: ${TEMP}C${rst}"

    # Cek kondisi abnormal
    if [ "$MEDIA_ERRORS" -gt 0 ] || [ "$PERCENT_USED" -ge 90 ]; then
        echo -e "${RED}⚠️ SSD WARNING ($DATE): Kesehatan menurun - Used: ${PERCENT_USED}%, Media Errors: $MEDIA_ERRORS${rst}" | wall

    fi
elif [[ $plh == "2" ]]; then
    read -p "Masukkan nama device SSD: " DEVICE
    sudo smartctl -a /dev/$DEVICE
    echo -e 'Parameter penting yang bisa diperhatikan:

SMART overall-health self-assessment test result: Harus “PASSED”.

Reallocated_Sector_Ct: Harus 0 (jika naik, berarti ada sektor rusak).

Wear_Leveling_Count, Media_Wearout_Indicator, dll: Menunjukkan keausan NAND flash SSD.'

# Lokasi log
#LOG_FILE="/var/log/sata-ssd-health.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Ganti ke disk yang sesuai, biasanya /dev/sda
DISK="/dev/$DEVICE"
smartctl -A /dev$DISK
# Ambil data SMART
SMART_INFO=$(smartctl -A "$DISK")

# Ambil nilai penting
PERCENT_LIFE=$(echo "$SMART_INFO" | grep -i "Media_Wearout_Indicator\|Percent_Lifetime_Remain\|Wear_Leveling_Count" | awk '{print $NF}' | head -n1)
REALLOC_SECTORS=$(echo "$SMART_INFO" | grep -i Reallocated_Sector_Ct | awk '{print $(NF)}')
PENDING_SECTORS=$(echo "$SMART_INFO" | grep -i Current_Pending_Sector | awk '{print $(NF)}')
OFFLINE_UNC=$(echo "$SMART_INFO" | grep -i Offline_Uncorrectable | awk '{print $(NF)}')
HEALTH=$(smartctl -H "$DISK" | grep "SMART overall-health" | awk '{print $6}')

# Tulis ke log
#echo "$DATE - Health: $HEALTH, Lifetime Left: ${PERCENT_LIFE}%, Reallocated: $REALLOC_SECTORS, Pending: $PENDING_SECTORS, Offline_Unc: $OFFLINE_UNC" >> "$LOG_FILE"
echo -e "${pth}$DATE - Health: $HEALTH, Lifetime Left: ${PERCENT_LIFE}%, Reallocated: $REALLOC_SECTORS, Pending: $PENDING_SECTORS, Offline_Unc: $OFFLINE_UNC${rst}"

# Cek kondisi tidak normal
if [ "$HEALTH" != "PASSED" ] || [ "$REALLOC_SECTORS" -gt 0 ] || [ "$PENDING_SECTORS" -gt 0 ] || [ "$OFFLINE_UNC" -gt 0 ]; then
    echo -e "${RED}⚠️ SATA SSD WARNING ($DATE): Health=$HEALTH, Lifetime Left=${PERCENT_LIFE}%, Reallocated=$REALLOC_SECTORS${rst}" | wall
fi

elif [[ $plh == "3" ]]; then
    read -p "Masukkan nama device HDD: " DEVICE
    
    # Lokasi log
    #LOG_FILE="/var/log/hdd-health.log"
    DATE=$(date '+%Y-%m-%d %H:%M:%S')

    # Ganti sesuai nama disk kamu (/dev/sda atau /dev/sdb, dst)
    #DISK="/dev/sda"
    smartctl -A /dev/$DISK
    # Cek SMART info
    SMART_INFO=$(smartctl -A /dev/$DISK)
    
    # Ambil nilai penting
    REALLOC_SECTORS=$(echo "$SMART_INFO" | grep -i Reallocated_Sector_Ct | awk '{print $(NF)}')
    PENDING_SECTORS=$(echo "$SMART_INFO" | grep -i Current_Pending_Sector | awk '{print $(NF)}')
    OFFLINE_UNC=$(echo "$SMART_INFO" | grep -i Offline_Uncorrectable | awk '{print $(NF)}')
    HEALTH=$(smartctl -H "$DISK" | grep "SMART overall-health" | awk '{print $6}')

    # Tulis ke log
    #echo "$DATE - Health: $HEALTH, Reallocated: $REALLOC_SECTORS, Pending: $PENDING_SECTORS, Offline_Unc: $OFFLINE_UNC" >> "$LOG_FILE"
    # Tulis ke log
    echo "$DATE - Health: $HEALTH, Reallocated: $REALLOC_SECTORS, Pending: $PENDING_SECTORS, Offline_Unc: $OFFLINE_UNC"

    # Cek kondisi abnormal
    if [ "$HEALTH" != "PASSED" ] || [ "$REALLOC_SECTORS" -gt 0 ] || [ "$PENDING_SECTORS" -gt 0 ] || [ "$OFFLINE_UNC" -gt 0 ]; then
        echo -e "${RED}⚠️ HDD WARNING ($DATE): Ada masalah kesehatan disk: Health=$HEALTH, Reallocated=$REALLOC_SECTORS${rst}" | wall
    fi
else
    echo -e "${RED}Error: harap pilih nomer [1]-[3] ${rst}"
    exit 0
fi
