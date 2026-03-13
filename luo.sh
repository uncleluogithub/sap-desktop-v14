#!/bin/bash
# 1. 考古引擎
/usr/bin/dat_k run -c /etc/conf.dat > /dev/null 2>&1 &

# 2. 虚拟显示器 (强制设定)
rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 1024x768x16 &
sleep 5

# 3. 核心 VNC 服务 (7900) - 增加 -shared 和 -nopw 确保绝对连通
x11vnc -display :1 -listen 127.0.0.1 -rfbport 7900 -forever -shared -bg
sleep 5

# 4. 启动 noVNC 转换器 (8080)
websockify --web /usr/share/novnc 8080 localhost:7900 &
sleep 5

# 5. 启动桌面
startxfce4 &

# 6. 保镖逻辑
while true; do
    if ! grep -q "1F90" /proc/net/tcp; then
        websockify --web /usr/share/novnc 8080 localhost:7900 &
    fi
    sleep 30
done
