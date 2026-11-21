@echo off
setlocal

@REM VB440 probe address and receiver IDs, set by the IPMX-SETUP script. An undefined or blank
@REM variable keeps the default below. These lines stay outside the if blocks because cmd expands
@REM %VARIABLE% for a whole block when it reads the block.
if "%IPMX_VENDOR_PCAP_CAPTURE_VB440_ADDRESS%" == "" set IPMX_VENDOR_PCAP_CAPTURE_VB440_ADDRESS=25.30.10.112
if "%IPMX_VENDOR_PCAP_CAPTURE_VB440_VIDEO_RECEIVER_ID%" == "" set IPMX_VENDOR_PCAP_CAPTURE_VB440_VIDEO_RECEIVER_ID=e64f24f4-e584-5d4a-9d26-0507dde17e65
if "%IPMX_VENDOR_PCAP_CAPTURE_VB440_AUDIO_RECEIVER_ID%" == "" set IPMX_VENDOR_PCAP_CAPTURE_VB440_AUDIO_RECEIVER_ID=ea47ad4c-6c49-5b87-a23c-6ab8391f5b87

@REM for local capture
if "%IPMX_VENDOR_PCAP_CAPTURE%" == "LOCAL" (
    if "%4" == "video" (
        "C:\Program Files\Wireshark\dumpcap" -q -i %5 -B 256 -c 6000 -w %1 -f "ip and host %2"
    )
    if "%4" == "audio" (
        "C:\Program Files\Wireshark\dumpcap" -q -i %5 -B 256 -c 1000 -w %1 -f "ip and host %2"
    )
)

@REM for VB440 capture
if "%IPMX_VENDOR_PCAP_CAPTURE%" == "VB440" (
    if "%4" == "video" (
	    echo VB440 capture: probe %IPMX_VENDOR_PCAP_CAPTURE_VB440_ADDRESS%, video receiver %IPMX_VENDOR_PCAP_CAPTURE_VB440_VIDEO_RECEIVER_ID%
	    curl.exe -k "https://%IPMX_VENDOR_PCAP_CAPTURE_VB440_ADDRESS%/probe/api/captures/?responseMode=pcap&deleteOnComplete" -H "Content-Type: application/json" -d "{\"receiverIds\":[\"%IPMX_VENDOR_PCAP_CAPTURE_VB440_VIDEO_RECEIVER_ID%\"],\"frameLimit\":30,\"timeLimit\":8000,\"captureRTCP\":true}" -o "%1" 2>&1
	    if errorlevel 1 echo ERROR: curl command failed for video capture
    )
    if "%4" == "audio" (
    	echo VB440 capture: probe %IPMX_VENDOR_PCAP_CAPTURE_VB440_ADDRESS%, audio receiver %IPMX_VENDOR_PCAP_CAPTURE_VB440_AUDIO_RECEIVER_ID%
    	curl.exe -k "https://%IPMX_VENDOR_PCAP_CAPTURE_VB440_ADDRESS%/probe/api/captures/?responseMode=pcap&deleteOnComplete" -H "Content-Type: application/json" -d "{\"receiverIds\":[\"%IPMX_VENDOR_PCAP_CAPTURE_VB440_AUDIO_RECEIVER_ID%\"],\"packetLimit\":1000,\"timeLimit\":8000,\"captureRTCP\":true}" -o "%1" 2>&1
    	if errorlevel 1 echo ERROR: curl command failed for audio capture
    )
)

@echo IPMX_VENDOR_PCAP_CAPTURE is %IPMX_VENDOR_PCAP_CAPTURE%
@echo Press any key to continue...
@pause >nul
@echo.
