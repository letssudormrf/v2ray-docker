#!/usr/bin/env sh

# Function Definition
set_projectv_var() {
    export $1="$(find /usr/local/share/v2cfg -type f -name "*.tmpl" | grep "$2" | xargs cat)"
}

# [Log:vars]
export ACCESS_LOG=${ACCESS_LOG:-"/dev/null"}
export ERROR_LOG=${ERROR_LOG:-"/dev/stderr"}
export LOG_LEVEL=${LOG_LEVEL:-"warning"}
export CADDY_LOG=${CADDY_LOG:-"/dev/null"}

# [Mode:vars]
# 1)ws+tls mode
#   value:ws (default)
#   v2ray port:8880/tcp
#   caddy port:{ws:8080/tcp,wss:8443/tcp}
export MODE=${MODE:-"ws"}

# [ClientID:vars]
export UUID=${UUID:-"117ff1a7-d810-4ec7-b368-6fc4491a4435"}
export ALTERID=${ALTERID:-"0"}

# [Path:vars]
export WSPATH=${WSPATH:-"/v2/"}

# [Let'sencrypt_Domain:vars]
export DOMAIN=${DOMAIN:-"0.0.0.0"}

# [Failover_Domain:vars]
export FAILOVER=${FAILOVER:-"www.example.com"}

# [Caddy_TLS_Option:vars]
export TLS=${TLS:-"self_signed"}

# [CERT:vars]
# For creating the certificates, should replace all the new line characters with "\n" in vars
export CERT=${CERT:-""}
export KEY=${KEY:-""}
if [ "$CERT" != "$KEY" ]; then
    echo -e "$CERT" > ${V2RAY_LOCATION_CONFIG}cert.pem
    echo -e "$KEY"  > ${V2RAY_LOCATION_CONFIG}key.pem
fi

# [SOCKS5PROXY:vars]
# For using SOCKS5PROXY, set env (e.g. PROXY=ON)
export PROXY=${PROXY:-""}
export PROXYIP=${PROXYIP:-"127.0.0.1"}
export PROXYPORT=${PROXYPORT:-"1080"}

# [External_DNS:vars]
export EXT_DNS=${EXT_DNS:-""}
export NAMESERVER1=${NAMESERVER1:-"8.8.8.8"}
export NAMESERVER2=${NAMESERVER2:-"8.8.4.4"}

# [ProjectV_CONFIG:vars]
export CONFIG=${CONFIG:-""}
export HEADER_NUM=${HEADER_NUM:-"001"}
export LOG_NUM=${LOG_NUM:-"010"}
export API_NUM=${API_NUM:-"020"}
export DNS_NUM=${DNS_NUM:-"030"}
export STATS_NUM=${STATS_NUM:-"040"}
export ROUTING_NUM=${ROUTING_NUM:-"050"}
export POLICY_NUM=${POLICY_NUM:-"060"}
export INBOUND_NUM=${INBOUND_NUM:-"070"}
export OUTBOUND_NUM=${OUTBOUND_NUM:-"080"}
export INBOUNDDETOUR_NUM=${INBOUNDDETOUR_NUM:-"090"}
export OUTBOUNDDETOUR_NUM=${OUTBOUNDDETOUR_NUM:-"100"}
export TRANSPORT_NUM=${TRANSPORT_NUM:-"110"}
export FOOTER_NUM=${FOOTER_NUM:-"999"}

# [Caddyfile_CONFIG:vars]
export CADDYFILE_NUM=${CADDYFILE_NUM:-"001"}
export FORWARDPROXY=${FORWARDPROXY:-""} 
export BASICAUTH=${BASICAUTH:-"h2user h2secret"}
export DIAL_TIMEOUT=${DIAL_TIMEOUT:-"600"}
export PROBE_RESISTANCE=${PROBE_RESISTANCE:-""}

if [ ! -z "$PROXY" ]; then
    export OUTBOUND_NUM="081"
fi

if [ ! -z "$EXT_DNS" ]; then
    export DNS_NUM="031"
fi

if [ ! -z "$FORWARDPROXY" ]; then
    export CADDYFILE_NUM="002"    
fi

if [ ! -z "$PROBE_RESISTANCE" ]; then
    export PROBE_RESISTANCE=$(echo "probe_resistance ${PROBE_RESISTANCE}")
fi

# ProjectV render
if [ -z "$HEADER" ]; then
    set_projectv_var HEADER         $HEADER_NUM
fi

if [ -z "$LOG" ]; then
    set_projectv_var LOG            $LOG_NUM
fi

if [ -z "$API" ]; then
    set_projectv_var API            $API_NUM
fi

if [ -z "$DNS" ]; then
    set_projectv_var DNS            $DNS_NUM
fi

if [ -z "$STATS" ]; then
    set_projectv_var STATS          $STATS_NUM
fi

if [ -z "$ROUTING" ]; then
    set_projectv_var ROUTING        $ROUTING_NUM
fi

if [ -z "$POLICY" ]; then
    set_projectv_var POLICY         $POLICY_NUM
fi

if [ -z "$INBOUND" ]; then
    set_projectv_var INBOUND        $INBOUND_NUM
fi

if [ -z "$OUTBOUND" ]; then
    set_projectv_var OUTBOUND       $OUTBOUND_NUM
fi

if [ -z "$INBOUNDDETOUR" ]; then
    set_projectv_var INBOUNDDETOUR  $INBOUNDDETOUR_NUM
fi

if [ -z "$OUTBOUNDDETOUR" ]; then
    set_projectv_var OUTBOUNDDETOUR $OUTBOUNDDETOUR_NUM
fi

if [ -z "$TRANSPORT" ]; then
    set_projectv_var TRANSPORT      $TRANSPORT_NUM
fi

if [ -z "$FOOTER" ]; then
    set_projectv_var FOOTER         $FOOTER_NUM
fi

if [ -z "$CONFIG" ]; then
    export CONFIG="$(cat <<-EOF
$HEADER
$LOG
$API
$DNS
$STATS
$ROUTING
$POLICY
$INBOUND
$OUTBOUND
$INBOUNDDETOUR
$OUTBOUNDDETOUR
$TRANSPORT
$FOOTER
EOF
    )"
fi

envsubst < /usr/local/share/caddycfg/${CADDYFILE_NUM}_Caddyfile.tmpl > ${CADDYPATH}Caddyfile
echo "$CONFIG" | envsubst > ${V2RAY_LOCATION_CONFIG}config.json

nohup caddy -conf ${CADDYPATH}Caddyfile -log ${CADDY_LOG} -http-port ${HTTP_PORT} -https-port ${HTTPS_PORT} -agree=true -root=${CADDYPATH}html &
v2ray -config ${V2RAY_LOCATION_CONFIG}config.json
