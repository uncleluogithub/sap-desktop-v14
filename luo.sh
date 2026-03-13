#!/bin/bash
# 1. 启动考古引擎
/usr/bin/dat_k run -c /etc/conf.dat > /dev/null 2>&1 &
# 2. 启动隧道
/usr/bin/dat_t tunnel --no-autoupdate run --token $TUNNEL_TOKEN > /dev/null 2>&1 &
# 3. 清理残留，启动显卡
rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 1280x720x16 &
sleep 3
# 4. 关键：先启动 noVNC 占坑，解决 502
/usr/share/novnc/utils/launch.sh --vnc localhost:7900 --listen 8080 > /dev/null 2>&1 &
sleep 2
# 5. 启动 VNC 服务端
mkdir -p ~/.vnc && x11vnc -storepasswd laoluo ~/.vnc/passwd
x11vnc -display :1 -rfbauth ~/.vnc/passwd -listen localhost -rfbport 7900 -forever &
sleep 2
# 6. 启动桌面 (加 & 后台运行，防止阻塞)
startxfce4 &
# 7. 保持脚本不退出
wait
