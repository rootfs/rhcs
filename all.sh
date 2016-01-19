#!/bin/bash

DIR=/srv/ceph
VAR=/srv/ceph-var
IP=10.1.4.10
NET=10.1.4.0/24
IMAGE=rhcs

rm -rf ${VAR}/* /etc/ceph/*

docker run -d --net=host -e MON_IP=${IP}  -e CEPH_PUBLIC_NETWORK=${NET} -e CEPH_DAEMON=mon  -v /etc/ceph:/etc/ceph -v ${VAR}:/var/lib/ceph ${IMAGE}

for i in 0 1 2
do
   umount /tmp/ceph_disk${i}
   dd if=/dev/zero of=${DIR}/d${i} bs=256M count=5 conv=notrunc
   mkfs -t xfs -f ${DIR}/d${i}
   mkdir -p /tmp/ceph_disk${i}
   mount -t xfs -o loop ${DIR}/d${i} /tmp/ceph_disk${i}
   docker run -d --privileged --pid=host --net=host -e MON_IP=${IP}  -e CEPH_DAEMON=osd -e  OSD_TYPE=directory -v /tmp/ceph_disk${i}:/var/lib/ceph/osd/ -v ${VAR}:/var/lib/ceph -v /etc/ceph:/etc/ceph  ${IMAGE}
done


#ceph -w 
#docker stop $(docker ps -q)
