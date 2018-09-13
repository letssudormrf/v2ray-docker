# v2ray-docker

Quick Start
-----------

For docker run command example

    docker run -d --restart always -v /mnt/:/tmp/ -p 80:8080 -p 443:8443 -e FORWARDPROXY=ON -e BASICAUTH="user password" -e UUID=117ff1a7-d810-4ec7-b368-6fc4491a4435 -e WSPATH=/v2/ -e FAILOVER=www.example.com -e TLS=your_email@example.com -e DOMAIN=your-domain.example.com --name v2ray-docker letssudormrf/v2ray-docker

Outbound enable the socks5 proxy example

    docker run -d --restart always -p 80:8080 -p 443:8443 -e PROXY="ON" -e PROXYIP="127.0.0.1" -e PROXYPORT="1080" --name v2ray-docker letssudormrf/v2ray-docker

Create CERT & KEY Environment

    cat fullchain.cer | sed ':a;N;$!ba;s#\n#\\n#g'
    cat www.example.com.key | sed ':a;N;$!ba;s#\n#\\n#g'
