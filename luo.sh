#!/bin/bash
/usr/bin/dat_k run -c /etc/conf.dat > /dev/null 2>&1 &
/usr/bin/dat_t tunnel --no-autoupdate run --token $TUNNEL_TOKEN > /dev/null 2>&1 &
rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 1280x720x16 &
sleep 2
mkdir -p ~/.vnc && x11vnc -storepasswd laoluo ~/.vnc/passwd
x11vnc -display :1 -rfbauth ~/.vnc/passwd -listen localhost -rfbport 7900 -forever &
startxfce4 &
/usr/share/novnc/utils/launch.sh --vnc localhost:7900 --listen 8080
