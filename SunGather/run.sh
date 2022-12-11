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

if ! bashio::services.available "mqtt"; then
   bashio::exit.nok "No internal MQTT Broker found. Please install Mosquitto broker."
else
    MQTT_HOST=$(bashio::services mqtt "host")
    MQTT_PORT=$(bashio::services mqtt "port")
    MQTT_USER=$(bashio::services mqtt "username")
    MQTT_PASS=$(bashio::services mqtt "password")
    bashio::log.info "Configured '$MQTT_HOST' mqtt broker."
fi

yq -i "
  .inverter.host = \"$INVERTER_HOST\" |
  .inverter.scan_interval = $INTERVAL |
  .inverter.connection = \"$CONNECTION\" |
  .inverter.smart_meter = $SMART_METER |
  .inverter.log_console = \"$LOG_CONSOLE\" |
  .inverter.level = $LEVEL
" /share/SunGather/config.yaml
yq -i "
  (.exports[] | select(.name == \"mqtt\") | .enabled) = True |
  (.exports[] | select(.name == \"mqtt\") | .host) = \"$MQTT_HOST\" |
  (.exports[] | select(.name == \"mqtt\") | .port) = $MQTT_PORT |
  (.exports[] | select(.name == \"mqtt\") | .homeassistant) = True
" /share/SunGather/config.yaml
yq -i "
  (.exports[] | select(.name == \"webserver\") | .enabled) = $WEBUI
" /share/SunGather/config.yaml

exec python3 /sungather.py -c /share/SunGather/config.yaml -l /share/SunGather/