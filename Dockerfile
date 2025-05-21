FROM python:3.12-slim-bookworm

RUN apt update
RUN apt install -y gcc python3-dev
RUN apt install -y mdadm
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /opt/hass_mqtt_raid_status
COPY . /opt/hass_mqtt_raid_status
RUN pip --no-cache-dir install -e /opt/hass_mqtt_raid_status

# ENTRYPOINT ["/usr/local/bin/check-raid.py"]
ENTRYPOINT ["/opt/hass_mqtt_raid_status/check-raid.py"]
CMD ["-v", "-c", "/config/config.json"]
