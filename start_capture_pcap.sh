#!/bin/bash
# VB440 probe address and receiver IDs, set by the IPMX-SETUP script. An undefined or blank
# variable keeps the default below.
if [ -z "$IPMX_VENDOR_PCAP_CAPTURE_VB440_ADDRESS" ]; then
    IPMX_VENDOR_PCAP_CAPTURE_VB440_ADDRESS=25.30.10.112
fi

if [ -z "$IPMX_VENDOR_PCAP_CAPTURE_VB440_VIDEO_RECEIVER_ID" ]; then
    IPMX_VENDOR_PCAP_CAPTURE_VB440_VIDEO_RECEIVER_ID=e64f24f4-e584-5d4a-9d26-0507dde17e65
fi

if [ -z "$IPMX_VENDOR_PCAP_CAPTURE_VB440_AUDIO_RECEIVER_ID" ]; then
    IPMX_VENDOR_PCAP_CAPTURE_VB440_AUDIO_RECEIVER_ID=ea47ad4c-6c49-5b87-a23c-6ab8391f5b87
fi

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
        echo "VB440 capture: probe $IPMX_VENDOR_PCAP_CAPTURE_VB440_ADDRESS, video receiver $IPMX_VENDOR_PCAP_CAPTURE_VB440_VIDEO_RECEIVER_ID"
        curl -k "https://$IPMX_VENDOR_PCAP_CAPTURE_VB440_ADDRESS/probe/api/captures/?responseMode=pcap&deleteOnComplete" -H "Content-Type: application/json" -d "{\"receiverIds\":[\"$IPMX_VENDOR_PCAP_CAPTURE_VB440_VIDEO_RECEIVER_ID\"],\"frameLimit\":30,\"timeLimit\":8000,\"captureRTCP\":true}" -o "$1" 2>&1
        if [ $? -ne 0 ]; then echo "ERROR: curl command failed for video capture"; fi
    fi
    if [ "$4" == "audio" ]; then
        echo "VB440 capture: probe $IPMX_VENDOR_PCAP_CAPTURE_VB440_ADDRESS, audio receiver $IPMX_VENDOR_PCAP_CAPTURE_VB440_AUDIO_RECEIVER_ID"
        curl -k "https://$IPMX_VENDOR_PCAP_CAPTURE_VB440_ADDRESS/probe/api/captures/?responseMode=pcap&deleteOnComplete" -H "Content-Type: application/json" -d "{\"receiverIds\":[\"$IPMX_VENDOR_PCAP_CAPTURE_VB440_AUDIO_RECEIVER_ID\"],\"packetLimit\":1000,\"timeLimit\":8000,\"captureRTCP\":true}" -o "$1" 2>&1
        if [ $? -ne 0 ]; then echo "ERROR: curl command failed for audio capture"; fi
    fi
fi

echo "IPMX_VENDOR_PCAP_CAPTURE is $IPMX_VENDOR_PCAP_CAPTURE"
read -p "Press any key to continue..." -n 1
echo
