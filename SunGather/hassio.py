import logging
import requests
import datetime
import time

class export_hassio(object):
    #def __init__(self):
        # Nothing

    @property
    def headers(self):
        return {
            "Content-Type: application/json",
            "Authorization: Bearer " + {self.hassio_config['token']}
        }

    def configure(self, config, inverter):
        self.hassio_config = {
            'api_url': config.get('api_url', None),
            'token': config.get('token', None),
        }

        self.ha_sensors = [{}]
        self.ha_sensors.pop() # Remove null value from list

        for ha_sensor in config.get('ha_sensors'):
            if not inverter.validateRegister(ha_sensor['register']):
                logging.error(f"MQTT: Configured to use {ha_sensor['register']} but not configured to scrape this register")
                return False
            else:
                self.ha_sensors.append(ha_sensor)

        logging.info(f"HASSIO: Configured Endpoint {self.hassio_config['api_url']}, TOKEN: {self.hassio_config['token']}")
        return True

    def cleanName(self, name):
        return name.lower().replace(' ','_')

    def publish(self, inverter):
        for ha_sensor in self.ha_sensors:
            payload = {}
            attributes = {}

            payload['state'] = inverter.getRegisterValue(ha_sensor.get('register'))
            attributes['unit_of_measurement'] = ha_sensor.get('unit_of_measurement')
            attributes['dev_class'] = ha_sensor.get('dev_class')
            attributes['state_class'] = ha_sensor.get('state_class')

            payload['attributes'] = attributes

            logging.info("HASSIO: api_url;" + str(self.hassio_config['api_url']))
            logging.info("HASSIO: sensor_type;" + str(ha_sensor.get('sensor_type')))
            logging.info("HASSIO: name;" + str(ha_sensor.get('name')))

            logging.info("HASSIO: payload;" + str(payload))

            try:
                sensor_endpoint = self.hassio_config['api_url'] + '/states/' + ha_sensor.get('sensor_type') + '.sungather_' + self.cleanName(ha_sensor.get('name'))
                logging.info("HASSIO: Endpoint; " + str(sensor_endpoint) + "; " + str(self.headers) + "; " + str(payload))

                response = requests.post(url=sensor_endpoint, headers=self.headers, params=payload, timeout=3)

                if response.status_code != requests.codes.ok:
                    logging.error(f"HASSIO: Update Failed; {str(response.status_code)} Message; {str(response.text)}")
                    logging.error("HASSIO: Endpoint; " + str(sensor_endpoint) + "; " + str(self.headers) + "; " + str(payload))
                else:
                    logging.info("HASSIO: Sensor:" + ha_sensor.get('name') + " Updated")
            except Exception as err:
                logging.error(f"HASSIO: Update Failed")
                logging.debug(f"{err}")



