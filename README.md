# MQTT linux RAID monitoring with Home Assistant auto configuration

Python script to monitor the RAID status provided by mdadm with home assistant auto configuration

## Changelog

- Containerize using Docker.
- Add RAID health boolean sensor.
- Migrate dependency management to `pyproject.toml` and `uv`.

## Sensors

 - RAID status (from mdadm) and health (binary)
 - Last update timestamp
 - Total disk space (default in TB, can be configured)
 - Free disk space
 - Free disk space in percent
 - Used disk space
 
 ![Sensors](https://raw.githubusercontent.com/sascha432/hass_mqtt_raid_status/master/sensors.png)
 ![Stats](https://raw.githubusercontent.com/sascha432/hass_mqtt_raid_status/master/stats.png)

## Requirements

- python 3.9 (other versions might work)
- paho-mqtt
- psutil
- mdadm, blkid, uname

Python requirements are installed when running with `uv`.

## Configuration

Edit `config.json` to change or add your device name and RAID devices

### Multiple RAID Devices

Any RAID device `/dev/mdX` can be added (`raid_device`). The device must be mounted (`mount_point`) to gather file system information

### Testing the Configuration

Execute `check-raid.py -v` as `root`. `mdadm` requires root privileges to be executed. If run as sudo has been enabled, the current user must be able to execute `sudo mdadm` without a password

### Installation as Service

#### Docker

Modify `docker-compose.yaml` to provide the container access to your mount points and RAID devices, then build and start the container.

```
docker compose up --build
```

#### systemd

Copy `hass_raid_status.service` to your systemd directory, modify the location of the python script and add any required services (for example mosquitto as dependency)

Enable, start and check the service with
```sh
systemctl enable hass_raid_status.service
systemctl start hass_raid_status.service
systemctl status hass_raid_status.service

● hass_raid_status.service - Raid status for Home Assistant
     Loaded: loaded (/etc/systemd/system/hass_raid_status.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2023-02-17 04:19:54 PST; 27ms ago
   Main PID: 14967 (python3)
      Tasks: 1 (limit: 4915)
        CPU: 14ms
     CGroup: /system.slice/hass_raid_status.service
             └─14967 python3 /root/hass_mqtt_raid_status/check-raid.py

```

## Home Assistant Integration

The device can be found under Configuration / Devices ([http://homeassistant.local:8123/config/devices/dashboard](http://homeassistant.local:8123/config/devices/dashboard))

![Devices](https://raw.githubusercontent.com/sascha432/hass_mqtt_raid_status/master/device.png)
![Entities](https://raw.githubusercontent.com/sascha432/hass_mqtt_raid_status/master/entities.png)

## Automated Alarm

To trigger any alarm if the RAID fails, you can add an automation if the state of the `healthy` binary sensor changes to false.

### Other States Observed

- Degraded mirrored RAID during rebuild `Clean,degraded,recovering`
- Degraded mirrored RAID with missing drive `Clean,degraded`

## TODO
- provide pre-built containers.
- improve documentation.
### Add More Sensors
Largely inspired by [HA_mdadm](https://github.com/LorenzoVasi/HA_mdadm).

- RAID type (e.g., raid1, raid5, etc; unclear if this will be useful after renaming entities)
- device count
- devices not working count
- sync (binary - unclear what this means, look up in HA_mdadm)
- resync details
  - current operation
  - progress (percent)
  - remaining time
  - speed
