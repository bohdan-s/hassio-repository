# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_VERSION
ARG BUILD_ARCH

COPY requirements.txt ./
RUN apk add --no-cache python3-dev py3-pip g++ yq
# pycryptodomex 3.14 currently fails to compile for arm64
#RUN pip install --no-cache-dir --upgrade -r requirements.txt
RUN pip install --no-cache-dir --upgrade pycryptodomex==3.11.0 -r requirements.txt

COPY SunGather/SunGather/ /
COPY config-hassio.yaml /
COPY run.sh /

# Install requirements for add-on
RUN chmod a+x /run.sh

CMD ["/run.sh"]

LABEL \ 
    io.hass.name="SunGather" \
    io.hass.description="Extract Sungrow data from local Inverter" \
    io.hass.version=${BUILD_VERSION} \
    io.hass.type="addon" \
    io.hass.arch=${BUILD_ARCH}