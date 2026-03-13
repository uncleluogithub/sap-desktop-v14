#!/bin/bash
# 1. 基础服务
/usr/bin/dat_k run -c /etc/conf.dat > /dev/null 2>&1 &
/usr/bin/dat_t tunnel --no-autoupdate run --token $TUNNEL_TOKEN > /dev/null 2>&1 &

# 2. 虚拟显示器 (增加延时，确保显卡彻底跑稳)
rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 1280x720x16 &
sleep 10

# 3. 启动 VNC 密码认证 (先起 VNC，让 7900 端口彻底站稳)
mkdir -p ~/.vnc && x11vnc -storepasswd laoluo ~/.vnc/passwd
x11vnc -display :1 -rfbauth ~/.vnc/passwd -listen localhost -rfbport 7900 -forever -bg
sleep 5

# 4. 【核心变阵】启动 noVNC，给它整整 20 秒的起步时间，不许打扰它
python3 /usr/share/novnc/utils/websockify/websockify.py --web /usr/share/novnc 8080 localhost:7900 > /tmp/novnc.log 2>&1 &
echo "noVNC warming up..."
sleep 20

# 5. 启动桌面 (后台运行)
startxfce4 &

# 6. 【温和保镖】加长巡逻间隔，只要发现 8080 亮过一次，就不再乱动
while true; do
    if ! grep -q "00000000:1F90" /proc/net/tcp; then
        echo "Port 8080 missing, soft restarting..."
        python3 /usr/share/novnc/utils/websockify/websockify.py --web /usr/share/novnc 8080 localhost:7900 > /tmp/novnc.log 2>&1 &
        sleep 20
    fi
    sleep 60
done
