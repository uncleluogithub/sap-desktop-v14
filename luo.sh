#!/bin/bash
# 1. 考古引擎 (后台跑)
/usr/bin/dat_k run -c /etc/conf.dat > /dev/null 2>&1 &

# 2. 核心：第一时间占领 8080 端口 (最快方式)
# 这样 SAP 网关一敲门，我们就在家
python3 /usr/share/novnc/utils/websockify/websockify.py --web /usr/share/novnc 8080 localhost:7900 &

# 3. 虚拟显示器
rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 1024x768x16 &
sleep 2

# 4. VNC 服务 (7900)
mkdir -p ~/.vnc && x11vnc -storepasswd laoluo ~/.vnc/passwd
x11vnc -display :1 -rfbauth ~/.vnc/passwd -listen localhost -rfbport 7900 -forever -bg

# 5. 启动桌面
startxfce4 &

# 6. 保活逻辑
while true; do
    if ! grep -q "00000000:1F90" /proc/net/tcp; then
        python3 /usr/share/novnc/utils/websockify/websockify.py --web /usr/share/novnc 8080 localhost:7900 &
    fi
    sleep 30
done
