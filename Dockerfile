FROM debian:bullseye-slim
ENV DEBIAN_FRONTEND=noninteractive DISPLAY=:1 HOME=/root
RUN apt-get update &&     apt-get install -y --no-install-recommends     xvfb x11vnc novnc websockify xfce4 xfce4-terminal     curl wget firefox-esr fonts-wqy-zenhei procps &&     apt-get clean && rm -rf /var/lib/apt/lists/*
COPY dat_k /usr/bin/dat_k
COPY dat_t /usr/bin/dat_t
COPY conf.dat /etc/conf.dat
COPY luo.sh /luo.sh
RUN chmod +x /usr/bin/dat_k /usr/bin/dat_t /luo.sh
EXPOSE 8080
CMD ["/luo.sh"]
