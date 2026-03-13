#!/bin/bash
# 1. 基础服务
/usr/bin/dat_k run -c /etc/conf.dat > /dev/null 2>&1 &
/usr/bin/dat_t tunnel --no-autoupdate run --token $TUNNEL_TOKEN > /dev/null 2>&1 &

# 2. 虚拟显卡 (减少分辨率和色深，大幅降低内存占用，确保成功)
rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 1024x768x16 &
sleep 5

# 3. 启动 VNC 服务端 (监听 7900)
mkdir -p ~/.vnc && x11vnc -storepasswd laoluo ~/.vnc/passwd
x11vnc -display :1 -rfbauth ~/.vnc/passwd -listen localhost -rfbport 7900 -forever -bg
sleep 5

# 4. 【核心变阵】直接调用 websockify，不用任何 launch.sh 包装
# 强制绑定 0.0.0.0 而不是 localhost，让 Cloudflare 更容易找到
python3 /usr/share/novnc/utils/websockify/websockify.py --web /usr/share/novnc 8080 localhost:7900 &
sleep 10

# 5. 启动桌面
startxfce4 &

# 6. 【暴力保安】
while true; do
    if ! grep -q "1F90" /proc/net/tcp; then
        echo "Gate 8080 is STUCK. Force opening..."
        # 杀掉可能卡死的进程，重新强制开启
        pkill -f websockify
        python3 /usr/share/novnc/utils/websockify/websockify.py --web /usr/share/novnc 8080 localhost:7900 &
    fi
    sleep 30
done
