#!/bin/bash
# 1. 考古引擎
/usr/bin/dat_k run -c /etc/conf.dat > /dev/null 2>&1 &

# 2. 核心：修正 websockify 调用方式
# Debian 默认安装后可以直接用 websockify 命令，无需找 python 文件
websockify --web /usr/share/novnc 8080 localhost:7900 &

# 3. 虚拟显示器
rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 1024x768x16 &
sleep 2

# 4. VNC 服务 (7900)
mkdir -p ~/.vnc && x11vnc -storepasswd laoluo ~/.vnc/passwd
x11vnc -display :1 -rfbauth ~/.vnc/passwd -listen localhost -rfbport 7900 -forever -bg

# 5. 启动桌面
startxfce4 &

# 6. 终极保安：直接查端口
while true; do
    if ! grep -q "1F90" /proc/net/tcp; then
        websockify --web /usr/share/novnc 8080 localhost:7900 &
    fi
    sleep 30
done
