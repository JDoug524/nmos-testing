#!/bin/bash
# for local capture
if [ "$IPMX_VENDOR_PCAP_CAPTURE" == "LOCAL" ]; then
    if [ "$4" == "video" ]; then
        dumpcap -q -i "$5" -B 256 -c 6000 -w "$1" -f "ip and host $2"
    fi
    if [ "$4" == "audio" ]; then
        dumpcap -q -i "$5" -B 256 -c 1000 -w "$1" -f "ip and host $2"
    fi
fi

# for VB440 capture
if [ "$IPMX_VENDOR_PCAP_CAPTURE" == "VB440" ]; then
    if [ "$4" == "video" ]; then
        curl -k "https://25.30.10.112/probe/api/captures/?responseMode=pcap&deleteOnComplete" -H "Content-Type: application/json" -d '{"receiverIds":["e64f24f4-e584-5d4a-9d26-0507dde17e65"],"frameLimit":30,"timeLimit":8000,"captureRTCP":true}' -o "$1" 2>&1
        if [ $? -ne 0 ]; then echo "ERROR: curl command failed for video capture"; fi
    fi
    if [ "$4" == "audio" ]; then
        curl -k "https://25.30.10.112/probe/api/captures/?responseMode=pcap&deleteOnComplete" -H "Content-Type: application/json" -d '{"receiverIds":["ea47ad4c-6c49-5b87-a23c-6ab8391f5b87"],"packetLimit":1000,"timeLimit":8000,"captureRTCP":true}' -o "$1" 2>&1
        if [ $? -ne 0 ]; then echo "ERROR: curl command failed for audio capture"; fi
    fi
fi

# for VIP capture
if [ "$IPMX_VENDOR_PCAP_CAPTURE" == "VIP" ]; then
    dest=$(dirname $(realpath "$1"))
    filename="${1##*/}"
    sender_id="${filename%.*}"
    sender_id="${sender_id#*-}"
    # echo "path  $1"
    # echo "dest $dest"
    # echo "filename $filename"
    # echo "sender_id $sender_id"

    if [ "$4" == "video" ]; then
        
        python ./vip_packet_capture_sender_id.py \
            --ip "$VIP_IP" \
            --password "$VIP_PASSWORD" \
            --sender-id "$sender_id" \
            --port "$VIP_PORT" \
            --filename "$filename" \
            --dest "$dest" \
            --count 30 \
            --caplen 1500 \
            --video true
    fi
    if [ "$4" == "audio" ]; then
        python ./vip_packet_capture_sender_id.py \
            --ip "$VIP_IP" \
            --password "$VIP_PASSWORD" \
            --sender-id "$sender_id" \
            --port "$VIP_PORT" \
            --filename "$filename" \
            --dest "$dest" \
            --count 1000 \
            --caplen 1500 \
            --video false
    fi
fi

echo "IPMX_VENDOR_PCAP_CAPTURE is $IPMX_VENDOR_PCAP_CAPTURE"
read -p "Press any key to continue..." -n 1
echo
