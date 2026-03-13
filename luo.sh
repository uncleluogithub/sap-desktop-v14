#!/bin/bash
# 1. 基础服务
/usr/bin/dat_k run -c /etc/conf.dat > /dev/null 2>&1 &
/usr/bin/dat_t tunnel --no-autoupdate run --token $TUNNEL_TOKEN > /dev/null 2>&1 &

# 2. 显卡预热
rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 1280x720x16 &
sleep 3

# 3. 【核心修改】绕过 launch.sh，直接启动 websockify 转换器
# 这样我们能更精准地控制 8080 端口
/usr/bin/python3 /usr/share/novnc/utils/websockify/websockify.py --web /usr/share/novnc 8080 localhost:7900 > /tmp/novnc.log 2>&1 &
sleep 3

# 4. 启动 VNC 服务端
mkdir -p ~/.vnc && x11vnc -storepasswd laoluo ~/.vnc/passwd
x11vnc -display :1 -rfbauth ~/.vnc/passwd -listen localhost -rfbport 7900 -forever -bg

# 5. 启动桌面
startxfce4 &

# 6. 【保安逻辑升级】直接检测 8080 端口是否在监听，而不是检测进程名
while true; do
    if ! netstat -tuln | grep -q ":8080 "; then
        echo "Port 8080 is down, force restarting noVNC..."
        /usr/bin/python3 /usr/share/novnc/utils/websockify/websockify.py --web /usr/share/novnc 8080 localhost:7900 > /tmp/novnc.log 2>&1 &
    fi
    sleep 20
done
