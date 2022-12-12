#!/usr/bin/with-contenv bashio

if [ ! -d /share/SunGather ]; then
  mkdir -p /share/SunGather
fi

if [ ! -f /share/SunGather/config.yaml ]; then
    cp config-example.yaml /share/SunGather/config.yaml
fi

INVERTER_HOST=$(bashio::config 'host')
INTERVAL=$(bashio::config 'scan_interval')
CONNECTION=$(bashio::config 'connection')
SMART_METER=$(bashio::config 'smart_meter')
LOG_CONSOLE=$(bashio::config 'log_console')
LEVEL=$(bashio::config 'level')
WEBUI=$(bashio::config 'webui')

yq -i "
  .inverter.host = \"$INVERTER_HOST\" |
  .inverter.scan_interval = $INTERVAL |
  .inverter.connection = \"$CONNECTION\" |
  .inverter.smart_meter = $SMART_METER |
  .inverter.log_console = \"$LOG_CONSOLE\" |
  .inverter.level = $LEVEL
" /share/SunGather/config.yaml

yq -i "
  (.exports[] | select(.name == \"hassio\") | .enabled) = True |
  (.exports[] | select(.name == \"hassio\") | .api_url) = \"http://supervisor/core/api\" |
  (.exports[] | select(.name == \"hassio\") | .token) = \"$SUPERVISOR_TOKEN\"
" /share/SunGather/config.yaml

yq -i "
  (.exports[] | select(.name == \"webserver\") | .enabled) = $WEBUI
" /share/SunGather/config.yaml

exec python3 /sungather.py -c /share/SunGather/config.yaml -l /share/SunGather/