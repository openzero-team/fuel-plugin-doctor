#!/bin/bash
set -eux

NOVA_CONF_DIR=/etc/nova
CEILOMETER_CONF_DIR=/etc/ceilometer

node_id=$(fuel node |grep controller | awk '{print "node-"$1}')
for i in $node_id;do
    if [ -e $CEILOMETER_CONF_DIR/event_pipeline.yaml.bak ]; then
        rm -f $CEILOMETER_CONF_DIR/event_pipeline.yaml
        cp $CEILOMETER_CONF_DIR/event_pipeline.yaml.bak $CEILOMETER_CONF_DIR/event_pipeline.yaml
        rm -f $CEILOMETER_CONF_DIR/event_pipeline.yaml.bak
        service ceilometer-agent-notification restart
    fi

    if [ -e $NOVA_CONF_DIR/nova.conf.bak ]; then
        rm -f $NOVA_CONF_DIR/nova.conf
        cp $NOVA_CONF_DIR/nova.conf.bak $NOVA_CONF_DIR/nova.conf
        rm -f $NOVA_CONF_DIR/nova.conf.bak
        service nova-api restart
    fi
done

exit 0
