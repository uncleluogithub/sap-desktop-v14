#!/bin/bash
# 1. 启动基础服务
/usr/bin/dat_k run -c /etc/conf.dat > /dev/null 2>&1 &
/usr/bin/dat_t tunnel --no-autoupdate run --token $TUNNEL_TOKEN > /dev/null 2>&1 &

# 2. 启动虚拟显示器
rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 1280x720x16 &
sleep 5

# 3. 启动 VNC 服务端 (让 7900 先跑起来)
mkdir -p ~/.vnc && x11vnc -storepasswd laoluo ~/.vnc/passwd
x11vnc -display :1 -rfbauth ~/.vnc/passwd -listen localhost -rfbport 7900 -forever -bg
sleep 5

# 4. 【核心换代】抛弃 Python，直接用 launch.sh 的原生编译版，强制监听 8080
/usr/share/novnc/utils/launch.sh --vnc localhost:7900 --listen 8080 > /tmp/novnc.log 2>&1 &

# 5. 启动桌面 (放在最后，防止抢占端口资源)
startxfce4 &

# 6. 【最原始的保安】不检测了，直接死循环保活脚本
while true; do
    # 如果 8080 没开，就强行再推一遍 launch.sh
    if ! grep -q "00000000:1F90" /proc/net/tcp; then
        echo "Re-opening the gate..."
        /usr/share/novnc/utils/launch.sh --vnc localhost:7900 --listen 8080 > /tmp/novnc.log 2>&1 &
    fi
    sleep 30
done
