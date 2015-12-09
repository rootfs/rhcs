FROM  registry.access.redhat.com/rhel7.2

MAINTAINER Huamin Chen "hchen@redhat.com"

LABEL Version="1.3" Description="This image has a running gluster deamon ( RHEL 7.1 + RHCS 1.3)"

ENV container docker

# This need to be removed later
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

RUN yum-config-manager --add=http://download.eng.blr.redhat.com/pub/rhel/released/RHEL-7/7.2/Server/x86_64/os/
RUN yum-config-manager --add=http://download.lab.bos.redhat.com/rel-eng/RHCeph/1.3-RHEL-7/latest/Server-RH7-CEPH-MON-1.3/x86_64/os/
RUN yum-config-manager --add=http://download.lab.bos.redhat.com/rel-eng/RHCeph/1.3-RHEL-7/latest/Server-RH7-CEPH-OSD-1.3/x86_64/os/
RUN yum-config-manager --add=http://download.eng.blr.redhat.com/pub/rhel/released/RHEL-7/7.2/Server-optional/x86_64/os/

RUN yum -y update; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

VOLUME [ “/sys/fs/cgroup/” ]


RUN yum -y install ceph --nogpgcheck; yum clean all;

# Fix for the issue - https://bugzilla.redhat.com/show_bug.cgi?id=1286665
RUN touch /etc/machine-id


# Editing /etc/redhat-storage-server release file
RUN echo "Red Hat Ceph Storage Server 1.3 ( Container)" > /etc/redhat-storage-release

EXPOSE 6789

ENTRYPOINT /usr/bin/sleep infinity