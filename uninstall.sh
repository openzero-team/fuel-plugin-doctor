#!/bin/bash
set -eux

cat > restore_doctor_conf.sh << 'END_TXT'
#!/bin/bash
set -eux

NOVA_CONF_DIR=/etc/nova
CEILOMETER_CONF_DIR=/etc/ceilometer

if [ -e /tmp/event_pipeline.yaml.bak ]; then
    rm -f $CEILOMETER_CONF_DIR/event_pipeline.yaml
    cp /tmp/event_pipeline.yaml.bak $CEILOMETER_CONF_DIR/event_pipeline.yaml
    rm -f /tmp/event_pipeline.yaml.bak
    service ceilometer-agent-notification restart
fi

if [ -e /tmp/nova.conf.bak ]; then
    rm -f $NOVA_CONF_DIR/nova.conf
    cp /tmp/nova.conf.bak $NOVA_CONF_DIR/nova.conf
    rm -f /tmp/nova.conf.bak
    service nova-api restart
 fi
exit 0
END_TXT

chmod +x restore_doctor_conf.sh

nodes=$(fuel node |grep controller | awk '{print "node-"$1}')
for node in $nodes;do
    scp restore_doctor_conf.sh "root@$node:"
    ssh "root@$node" './restore_doctor_conf.sh'
    sleep 2
    ssh "root@$node" 'rm -f restore_doctor_conf.sh'
done


