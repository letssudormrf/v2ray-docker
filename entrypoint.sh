#!/bin/sh

UUID=${UUID:-"49977c6d-44e6-4399-9293-87a80e3d958f"}
WSPATH=${WSPATH:-""}
TLS_MODE=${TLS_MODE:-""}

if [ -n "$TLS_MODE" ]; then
if [ "$CERT" != "$KEY" ]; then
  echo -e "$CERT" > /tmp/cert.pem
  echo -e "$KEY"  > /tmp/key.pem
fi
  CONFIG=${CONFIG:-'{"log":{"access":"/dev/stdout","error":"/dev/stderr","loglevel":"warning"},"inbound":{"port":8443,"protocol":"vmess","settings":{"clients":[{"id":"$UUID","level":1,"alterId":64}]},"streamSettings":{"network":"tcp","tlsSettings":{"certificates":[{"certificateFile":"/tmp/cert.pem","keyFile":"/tmp/key.pem"}]},"security":"tls"}},"outbound":{"protocol":"freedom","settings":{}},"outboundDetour":[{"protocol":"blackhole","settings":{},"tag":"blocked"}],"routing":{"strategy":"rules","settings":{"rules":[{"type":"field","ip":["0.0.0.0/8","10.0.0.0/8","100.64.0.0/10","127.0.0.0/8","169.254.0.0/16","172.16.0.0/12","192.0.0.0/24","192.0.2.0/24","192.168.0.0/16","198.18.0.0/15","198.51.100.0/24","203.0.113.0/24","::1/128","fc00::/7","fe80::/10"],"outboundTag":"blocked"}]}}}'}
else
  CONFIG=${CONFIG:-'{"log":{"access":"/dev/stdout","error":"/dev/stderr","loglevel":"warning"},"inbound":{"port":8080,"protocol":"vmess","settings":{"clients":[{"id":"$UUID","level":1,"alterId":64}]},"streamSettings":{"network":"ws","wsSettings":{"path":"$WSPATH"}}},"outbound":{"protocol":"freedom","settings":{}},"outboundDetour":[{"protocol":"blackhole","settings":{},"tag":"blocked"}],"routing":{"strategy":"rules","settings":{"rules":[{"type":"field","ip":["0.0.0.0/8","10.0.0.0/8","100.64.0.0/10","127.0.0.0/8","169.254.0.0/16","172.16.0.0/12","192.0.0.0/24","192.0.2.0/24","192.168.0.0/16","198.18.0.0/15","198.51.100.0/24","203.0.113.0/24","::1/128","fc00::/7","fe80::/10"],"outboundTag":"blocked"}]}}}'}
fi

echo -e "$CONFIG" | envsubst > /tmp/config.json

v2ray -config /tmp/config.json
