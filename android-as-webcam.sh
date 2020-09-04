##!/bin/bash

# Source recording options:
RECORD_WIDTH_PX=360
RECORD_HEIGHT_PX=640
RECORD_BIT_RATE=500000
RECORD_TIME_SECS=180  # Must be 180 seconds or lower. CAUTION: Stream will restart automatically after this time. Set it to a low value and test that your programs handle this properly.

# Specify a rectangle within the recording at an offset
# to which to crop. This can be useful to crop camera app
# elements from the webcam picture:
RECTANGLE_WIDTH_PX=360
RECTANGLE_HEIGHT_PX=240
OFFSET_PX_FROM_TOP=120
OFFSET_PX_FROM_LEFT=0


V4L2LOOPBACK_IS_PRESENT=$(lsmod | grep -c v4l2loopback)
if (( V4L2LOOPBACK_IS_PRESENT == 0 )); then
    echo "Kernel module 'v4l2loopback' is not present." \
	 "Install the package ('v4l2loopback-dkms' on Debian 10)," \
         "then run 'sudo insmod v4l2loopback'."
    exit 1
fi

# Start streaming command over for ever, because it
# terminates every 180 seconds.
trap "exit 0" SIGINT SIGTERM  # Terminate script when CTRL+C is pressed. Otherwise, the while loop would just start over.
while true; do
    adb shell -T  `# '-T' turns of pty for stdin/stdout, so we get just the raw bytes from the command` \
        screenrecord  `# Android built-in debugging screen recorder` \
        --output-format=h264  `# This option is not documented anywhere I can find, but it was necessary in my tests` \
        --size ${RECORD_WIDTH_PX}x${RECORD_HEIGHT_PX} \
        --bit-rate ${RECORD_BIT_RATE} \
        --time-limit=${RECORD_TIME_SECS}  `# Unfortunately these 180 seconds are the maximum time limit. The stream can, however be restarted after this runs out. v4l2loopback seems to handle this ok, all my tested programs just briefly froze the webcam display and picked up the stream again right away.` \
        - `# Write screen recording to Android stdout, which is transferred via the adb shell to the host running this bash script` \
    | ffmpeg \
    -probesize 32  `# Reduce time required for stream to start. This is important because it has to be restarted every 180 seconds (see above).` \
    -re  `# Use source framerate` \
    -i -  `# Read from stdin` \
    -filter:v "crop=${RECTANGLE_WIDTH_PX}:${RECTANGLE_HEIGHT_PX}:${OFFSET_PX_FROM_LEFT}:${OFFSET_PX_FROM_TOP}" \
    -f v4l2 \
    /dev/video0
done
