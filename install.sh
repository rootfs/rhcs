#!/bin/bash
function mon_systemd {
   cat <<EOF  > ${HOST}/etc/systemd/system/ceph-mon@${MON_NAME}.service
[Unit]
Description=Ceph Monitor
After=docker.service

[Service]
EnvironmentFile=/etc/environment
ExecStartPre=-/usr/bin/docker kill %p
ExecStartPre=-/usr/bin/docker rm %p
ExecStartPre=/usr/bin/mkdir -p /etc/ceph /var/lib/ceph/mon
ExecStart=/usr/bin/docker run -d --rm --name %p --net=host \
   -v /var/lib/ceph:/var/lib/ceph \
   -v /etc/ceph:/etc/ceph \
   --privileged \
   -e CEPH_DAEMON=MON \
   -e MON_IP=${MON_IP} \
   -e CEPH_PUBLIC_NETWORK=${CEPH_PUBLIC_NETWORK} \
   -e MON_NAME=${MON_NAME} \
   --name=${MON_NAME} \
   ${IMAGE}
ExecStopPost=-/usr/bin/docker stop %p
ExecStopPost=-/usr/bin/docker rm %p
Restart=always
RestartSec=10s
TimeoutStartSec=120
TimeoutStopSec=15

[Install]
WantedBy=multi-user.target
EOF
}

#PLACEHOLDER
function osd_systemd {
       cat <<EOF > ${HOST}/etc/systemd/system/ceph-mon@${MON_NAME}.service
[Unit]
Description=Ceph Monitor
After=docker.service

[Service]
EnvironmentFile=/etc/environment
ExecStartPre=-/usr/bin/docker kill %p
ExecStartPre=-/usr/bin/docker rm %p
ExecStartPre=/usr/bin/mkdir -p /etc/ceph /var/lib/ceph/mon
ExecStart=/usr/bin/docker run -d --rm --name %p --net=host --pid=host \
   -v /var/lib/ceph:/var/lib/ceph \
   -v /etc/ceph:/etc/ceph \
   -v /dev:/dev/ \
   --privileged \
   -e CEPH_DAEMON=OSD \
   -e MON_IP=${MON_IP} \
   -e CEPH_PUBLIC_NETWORK=${CEPH_PUBLIC_NETWORK} \
   --name=${OSD_NAME} \
   ${IMAGE}
ExecStopPost=-/usr/bin/docker stop %p
ExecStopPost=-/usr/bin/docker rm %p
Restart=always
RestartSec=10s
TimeoutStartSec=120
TimeoutStopSec=15

[Install]
WantedBy=multi-user.target
EOF
}


# Normalize DAEMON to lowercase
CEPH_DAEMON=$(echo ${CEPH_DAEMON} |tr '[:upper:]' '[:lower:]')
case "$CEPH_DAEMON" in
     mon)
         mon_systemd
         ;;
     *)
         if [ ! -n "$CEPH_DAEMON" ]; then
             echo "ERROR- One of CEPH_DAEMON or a daemon parameter must be defined as the name "
             echo "of the daemon you want to install."
             echo "Valid values for CEPH_DAEMON are MON, OSD, MDS, RGW, RESTAPI"
             exit 1
         fi
         ;;
esac
     
