#!/usr/bin/with-contenv bashio

#HOST=$(bashio::config 'host')
#TIMEOUT=$(bashio::config 'timeout')
#INTERVAL=$(bashio::config 'scan_interval')
#CONNECTION=$(bashio::config 'connection')
#SMART_METER=$(bashio::config 'smart_meter')
#LOG_CONSOLE=$(bashio::config 'log_console')
#LEVEL=$(bashio::config 'level')

#if ! bashio::services.available "mqtt"; then
#   bashio::exit.nok "No internal MQTT Broker found. Please install Mosquitto broker."
#else
#    MQTT_HOST=$(bashio::services mqtt "host")
#    MQTT_PORT=$(bashio::services mqtt "port")
#    MQTT_USER=$(bashio::services mqtt "username")
#    MQTT_PASS=$(bashio::services mqtt "password")
#    bashio::log.info "Configured'$MQTT_HOST' mqtt broker."
#fi

#yq -i '
#  .inverter.host = strenv(HOST) |
#  .inverter.scan_interval = strenv(INTERVAL) |
#  .inverter.connection = strenv(CONNECTION) |
#  .inverter.smart_meter = strenv(SMART_METER) |
#  .inverter.log_console = strenv(LOG_CONSOLE) |
#  .inverter.level = strenv(LEVEL) |
#  (.exports[] | select(.name == "mqtt") | .enabled) = true |
#  (.exports[] | select(.name == "mqtt") | .host) = strenv(MQTT_HOST) |
#  (.exports[] | select(.name == "mqtt") | .port) = strenv(MQTT_PORT) |
#  (.exports[] | select(.name == "mqtt") | .homeassistant) = true
#' /share/SunGather/config.yaml

exec python3 /sungather.py -c /share/SunGather/config.yaml -l /share/SunGather/