#!/bin/sh

# [Log:vars]
export ACCESS_LOG=${ACCESS_LOG:-"/dev/null"}
export ERROR_LOG=${ERROR_LOG:-"/dev/stderr"}
export LOG_LEVEL=${LOG_LEVEL:-"warning"}

# [Mode:vars]
# 1)ws+tls  value:ws (default)| bind:8880/tcp
# 2)tcp+tls value:tcp         | bind:8880/tcp
export MODE=${MODE:-"ws"}

# [ClientID:vars]
export UUID=${UUID:-"117ff1a7-d810-4ec7-b368-6fc4491a4435"}

# [Path:vars]
# Only use for ws mode
export WSPATH=${WSPATH:-"/v2/"}

# [failover Domain:vars]
export FAILOVER=${FAILOVER:-"www.example.com"}

# [CERT:vars]
# For creating the certificates, should replace all the new line characters with "\n" in vars
export CERT=${CERT:-""}
export KEY=${KEY:-""}
if [ "$CERT" != "$KEY" ]; then
    echo -e "$CERT" > /tmp/cert.pem
    echo -e "$KEY"  > /tmp/key.pem
fi

# [CONFIG:vars]
export CONFIG=${CONFIG:-""}

# Mode Selector
case "$MODE" in
ws)
    CONFIG=${CONFIG:-'{"log":{"access":"$ACCESS_LOG","error":"$ERROR_LOG","loglevel":"$LOG_LEVEL"},"inbound":{"port":8880,"protocol":"vmess","settings":{"clients":[{"id":"$UUID","level":1,"alterId":64}]},"streamSettings":{"network":"ws","wsSettings":{"path":"$WSPATH"}}},"outbound":{"protocol":"freedom","settings":{}},"outboundDetour":[{"protocol":"blackhole","settings":{},"tag":"blocked"}],"routing":{"strategy":"rules","settings":{"rules":[{"type":"field","ip":["0.0.0.0/8","10.0.0.0/8","100.64.0.0/10","127.0.0.0/8","169.254.0.0/16","172.16.0.0/12","192.0.0.0/24","192.0.2.0/24","192.168.0.0/16","198.18.0.0/15","198.51.100.0/24","203.0.113.0/24","::1/128","fc00::/7","fe80::/10"],"outboundTag":"blocked"}]}}}'}

    if [ ! -f /tmp/cert.pem ]; then
    openssl req -subj '/CN=www.example.com/O=Internet Corporation for Assigned Names and Numbers/C=US/OU=Technology' -new -x509 -sha256 -days 3650 -nodes -out /tmp/cert.pem -keyout /tmp/key.pem
    fi

    if [ "$FAILOVER" != "www.example.com" ]; then
        sed -i "s#www.example.com#$FAILOVER#g" /etc/nginx/conf.d/default.conf
    fi

    if [ "$WSPATH" != "/v2/" ]; then
        sed -i "s#/v2/#$WSPATH#g" /etc/nginx/conf.d/default.conf
    fi

    # Create nginx html folder
    if [ ! -d /tmp/html ]; then
        mkdir -p /tmp/html
    fi

    nginx -g "daemon on;"
    ;;
tcp)
    CONFIG=${CONFIG:-'{"log":{"access":"$ACCESS_LOG","error":"$ERROR_LOG","loglevel":"$LOG_LEVEL"},"inbound":{"port":8880,"protocol":"vmess","settings":{"clients":[{"id":"$UUID","level":1,"alterId":64}]},"streamSettings":{"network":"tcp","tlsSettings":{"certificates":[{"certificateFile":"/tmp/cert.pem","keyFile":"/tmp/key.pem"}]},"security":"tls"}},"outbound":{"protocol":"freedom","settings":{}},"outboundDetour":[{"protocol":"blackhole","settings":{},"tag":"blocked"}],"routing":{"strategy":"rules","settings":{"rules":[{"type":"field","ip":["0.0.0.0/8","10.0.0.0/8","100.64.0.0/10","127.0.0.0/8","169.254.0.0/16","172.16.0.0/12","192.0.0.0/24","192.0.2.0/24","192.168.0.0/16","198.18.0.0/15","198.51.100.0/24","203.0.113.0/24","::1/128","fc00::/7","fe80::/10"],"outboundTag":"blocked"}]}}}'}
    ;;
*)
    ;;
esac

echo -e "$CONFIG" | envsubst > /tmp/config.json

v2ray -config /tmp/config.json
