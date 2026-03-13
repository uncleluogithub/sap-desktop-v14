#!/bin/bash
# 1. 基础服务
/usr/bin/dat_k run -c /etc/conf.dat > /dev/null 2>&1 &
/usr/bin/dat_t tunnel --no-autoupdate run --token $TUNNEL_TOKEN > /dev/null 2>&1 &

# 2. 虚拟显示器
rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 1280x720x16 &
sleep 5

# 3. 启动 noVNC (直接用 python3 调用 websockify)
python3 /usr/share/novnc/utils/websockify/websockify.py --web /usr/share/novnc 8080 localhost:7900 > /tmp/novnc.log 2>&1 &
sleep 5

# 4. 启动 VNC 密码认证
mkdir -p ~/.vnc && x11vnc -storepasswd laoluo ~/.vnc/passwd
x11vnc -display :1 -rfbauth ~/.vnc/passwd -listen localhost -rfbport 7900 -forever -bg

# 5. 启动桌面
startxfce4 &

# 6. 【终极保安】直接读取内核 tcp 文件检测 1F90 (8080 的十六进制)
while true; do
    # 8080 端口的十六进制是 1F90
    if ! grep -q "00000000:1F90" /proc/net/tcp; then
        echo "Port 8080 not detected in /proc/net/tcp, restarting noVNC..."
        python3 /usr/share/novnc/utils/websockify/websockify.py --web /usr/share/novnc 8080 localhost:7900 > /tmp/novnc.log 2>&1 &
    fi
    sleep 30
done
