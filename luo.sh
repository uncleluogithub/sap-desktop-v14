#!/bin/bash
# 1. 基础服务 (后台运行)
/usr/bin/dat_k run -c /etc/conf.dat > /dev/null 2>&1 &
/usr/bin/dat_t tunnel --no-autoupdate run --token $TUNNEL_TOKEN > /dev/null 2>&1 &

# 2. 虚拟显示器
rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 1280x720x16 &
sleep 5

# 3. 【核心修正】先启动 noVNC 大门，确保 8080 端口第一时间亮起
# 使用 nohup 强制后台，防止它被桌面的启动压力杀掉
nohup /usr/share/novnc/utils/launch.sh --vnc localhost:7900 --listen 8080 > /tmp/novnc.log 2>&1 &
sleep 5

# 4. 启动 VNC 服务端
mkdir -p ~/.vnc && x11vnc -storepasswd laoluo ~/.vnc/passwd
x11vnc -display :1 -rfbauth ~/.vnc/passwd -listen localhost -rfbport 7900 -forever -bg

# 5. 启动桌面
startxfce4 &

# 6. 【最硬核的一行】死循环保活，只要这一行在，SAP 就不能判定应用结束
while true; do
    if ! pgrep -x "websockify" > /dev/null; then
        echo "noVNC dropped, restarting..."
        nohup /usr/share/novnc/utils/launch.sh --vnc localhost:7900 --listen 8080 > /tmp/novnc.log 2>&1 &
    fi
    sleep 30
done
