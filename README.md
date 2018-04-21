# v2ray-docker

Quick Start
-----------

For docker run command.

    docker run -d -p 80:8080/tcp -p 443:8443/udp --name v2ray-docker letssudormrf/v2ray-docker

Keep the Docker container running automatically after starting, add **--restart always**.

    docker run --restart always -d -p 80:8080/tcp -p 443:8443/udp --name v2ray-docker letssudormrf/v2ray-docker

Outbound enable the socks5 proxy

    docker run --restart always -d -p 80:8080/tcp -p 443:8443/udp -e CONFIG='{"log":{"access":"$ACCESS_LOG","error":"$ERROR_LOG","loglevel":"$LOG_LEVEL"},"inbound":{"port":8880,"protocol":"vmess","settings":{"clients":[{"id":"$UUID","level":1,"alterId":64}]},"streamSettings":{"network":"ws","wsSettings":{"path":"$WSPATH"}}},"outbound":{"protocol":"socks","settings":{"servers":[{"address":"$PROXYIP","port":$PROXYPORT}]}},"outboundDetour":[{"protocol":"blackhole","settings":{},"tag":"blocked"}],"routing":{"strategy":"rules","settings":{"rules":[{"type":"field","ip":["0.0.0.0/8","10.0.0.0/8","100.64.0.0/10","127.0.0.0/8","169.254.0.0/16","172.16.0.0/12","192.0.0.0/24","192.0.2.0/24","192.168.0.0/16","198.18.0.0/15","198.51.100.0/24","203.0.113.0/24","::1/128","fc00::/7","fe80::/10"],"outboundTag":"blocked"}]}}}' -e "PROXYIP=socks5-proxyip" -e PROXYPORT="1080" --name v2ray-docker letssudormrf/v2ray-docker

