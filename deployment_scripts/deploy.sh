#!/bin/bash

# Fuel Plugin - OPNFV Fault Managment (Doctor)
#
# https://wiki.opnfv.org/display/doctor
#
# Version 9.0

NOVA_CONF_DIR=/etc/nova
CEILOMETER_CONF_DIR=/etc/ceilometer


if [ -e $CEILOMETER_CONF_DIR/event_pipeline.yaml ]; then
    if ! grep -q '^ *- notifier://?topic=alarm.all$' $CEILOMETER_CONF_DIR/event_pipeline.yaml; then
        cp $CEILOMETER_CONF_DIR/event_pipeline.yaml $CEILOMETER_CONF_DIR/event_pipeline.yaml.bak
        sed -i 's|- notifier://|- notifier://?topic=alarm.all|' $CEILOMETER_CONF_DIR/event_pipeline.yaml
        service ceilometer-agent-notification restart
    fi
else
    echo "doctor plugin post deploy failed: ceilometer event_pipeline.yaml file is not exist"
    exit 1
fi

if [ -e $NOVA_CONF_DIR/nova.conf ]; then
    if ! grep -q '^notification_driver=messaging$' $NOVA_CONF_DIR/nova.conf; then
        cp $NOVA_CONF_DIR/nova.conf $NOVA_CONF_DIR/nova.conf.bak
        sed -i -r 's/notification_driver=/notification_driver=messaging/g' $NOVA_CONF_DIR/nova.conf
        service nova-api restart
    fi
else
    echo "doctor plugin post deploy failed: nova.conf file does not exist"
    exit 1
fi

exit 0
