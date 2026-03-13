FROM debian:bullseye-slim
ENV DEBIAN_FRONTEND=noninteractive DISPLAY=:1 HOME=/root
RUN     apt-get update &&     apt-get install -y --no-install-recommends     xvfb x11vnc novnc websockify xfce4 xfce4-terminal     curl wget firefox-esr fonts-wqy-zenhei procps &&     apt-get clean && rm -rf /var/lib/apt/lists/*
COPY dat_k /usr/bin/dat_k
COPY dat_t /usr/bin/dat_t
COPY conf.dat /etc/conf.dat
RUN chmod +x /usr/bin/dat_k /usr/bin/dat_t
RUN echo '#!/bin/bash\n/usr/bin/dat_k run -c /etc/conf.dat > /dev/null 2>&1 &\n/usr/bin/dat_t tunnel --no-autoupdate run --token $TUNNEL_TOKEN > /dev/null 2>&1 &\nrm -f /tmp/.X1-lock\nXvfb :1 -screen 0 1280x720x16 &\nsleep 2\nmkdir -p ~/.vnc && x11vnc -storepasswd laoluo ~/.vnc/passwd\nx11vnc -display :1 -rfbauth ~/.vnc/passwd -listen localhost -rfbport 7900 -forever &\nstartxfce4 &\n(sleep 5 && DISPLAY=:1 firefox-esr --new-window https://www.youtube.com &)\n/usr/share/novnc/utils/launch.sh --vnc localhost:7900 --listen 8080\n' > /luo.sh && chmod +x /luo.sh
EXPOSE 8080
CMD ["/luo.sh"]
