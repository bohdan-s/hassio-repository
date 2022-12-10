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

if ! bashio::services.available "mqtt"; then
   bashio::exit.nok "No internal MQTT Broker found. Please install Mosquitto broker."
else
    MQTT_HOST=$(bashio::services mqtt "host")
    MQTT_PORT=$(bashio::services mqtt "port")
    MQTT_USER=$(bashio::services mqtt "username")
    MQTT_PASS=$(bashio::services mqtt "password")
    bashio::log.info "Configured ' $MQTT_HOST ':' $MQTT_PORT ' mqtt broker."
fi

yq -i '
  .inverter.host = strenv(INVERTER_HOST) |
  .inverter.scan_interval = strenv(INTERVAL) |
  .inverter.connection = strenv(CONNECTION) |
  .inverter.smart_meter = strenv(SMART_METER) |
  .inverter.log_console = strenv(LOG_CONSOLE) |
  .inverter.level = strenv(LEVEL)
  ' /share/SunGather/config.yaml
yq -i '  
  (.exports[] | select(.name == "mqtt") | .enabled) = true |
  (.exports[] | select(.name == "mqtt") | .host) = strenv(MQTT_HOST) |
  (.exports[] | select(.name == "mqtt") | .port) = strenv(MQTT_PORT) |
  (.exports[] | select(.name == "mqtt") | .homeassistant) = true
' /share/SunGather/config.yaml

bashio::log.info $INVERTER_HOST $INTERVAL $CONNECTION $SMART_METER $LOG_CONSOLE $LEVEL $MQTT_HOST $MQTT_PORT $MQTT_USER $MQTT_PASS

exec python3 /sungather.py -c /share/SunGather/config.yaml -l /share/SunGather/