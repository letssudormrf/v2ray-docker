# v2ray-docker

Quick Start
-----------

For docker run command example

    docker run -d --restart always -v /mnt/:/tmp/ -p 80:8080 -p 443:8443 -e FORWARDPROXY=ON -e BASICAUTH="user password" -e UUID=117ff1a7-d810-4ec7-b368-6fc4491a4435 -e WSPATH=/v2/ -e FAILOVER=www.example.com -e TLS=your_email@example.com -e DOMAIN=your-domain.example.com --name v2ray-docker letssudormrf/v2ray-docker

Outbound enable the socks5 proxy example

    docker run -d --restart always -p 80:8080 -p 443:8443 -e PROXY="ON" -e PROXYIP="127.0.0.1" -e PROXYPORT="1080" --name v2ray-docker letssudormrf/v2ray-docker

Add MTProxy args, change to your own secret.

```
INBOUNDDETOUR='"inboundDetour":[{"tag":"tg-in","listen":"0.0.0.0","port":2053,"protocol":"mtproto","settings":{"users":[{"secret":"b0cbcef5a486d9636472ac27f8e11a9d"}]}}],'

OUTBOUNDDETOUR='"outboundDetour":[{"protocol":"blackhole","settings":{},"tag":"blocked"},{"tag":"tg-out","protocol":"mtproto","settings":{}}],'

ROUTING='"routing":{"strategy":"rules","settings":{"rules":[{"type":"field","inboundTag":["tg-in"],"outboundTag":"tg-out"},{"type":"field","ip":["0.0.0.0/8","10.0.0.0/8","100.64.0.0/10","127.0.0.0/8","169.254.0.0/16","172.16.0.0/12","192.0.0.0/24","192.0.2.0/24","192.168.0.0/16","198.18.0.0/15","198.51.100.0/24","203.0.113.0/24","::1/128","fc00::/7","fe80::/10"],"outboundTag":"blocked"}]}},'
```

Create CERT & KEY Environment

    cat fullchain.cer | sed ':a;N;$!ba;s#\n#\\n#g'
    cat www.example.com.key | sed ':a;N;$!ba;s#\n#\\n#g'
