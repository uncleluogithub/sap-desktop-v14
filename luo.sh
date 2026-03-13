#!/bin/bash
# 1. 考古引擎
/usr/bin/dat_k run -c /etc/conf.dat > /dev/null 2>&1 &

# 2. 降低分辨率和颜色 (800x600 是录制教学视频的黄金比例，极度流畅)
rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 800x600x16 &
sleep 5

# 3. 极简 VNC (7900)
x11vnc -display :1 -listen 127.0.0.1 -rfbport 7900 -forever -shared -bg
sleep 5

# 4. 转换器 (8080)
websockify --web /usr/share/novnc 8080 localhost:7900 &
sleep 5

# 5. 【流畅关键】限制 Firefox 的硬件加速，降低内存占用
export MOZ_FORCE_DISABLE_E10S=1
export DISPLAY=:1
dbus-run-session startxfce4 &

# 6. 保镖
while true; do
    if ! grep -q "1F90" /proc/net/tcp; then
        websockify --web /usr/share/novnc 8080 localhost:7900 &
    fi
    sleep 30
done
