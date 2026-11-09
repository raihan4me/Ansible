FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive container=docker

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      systemd systemd-sysv openssh-server sudo python3 python3-apt \
      iproute2 procps ca-certificates \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN systemctl mask getty.target console-getty.service systemd-logind.service \
 && systemctl enable ssh

RUN useradd -m -s /bin/bash ansible \
 && echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible \
 && chmod 0440 /etc/sudoers.d/ansible \
 && install -d -m 0700 -o ansible -g ansible /home/ansible/.ssh
COPY --chown=ansible:ansible authorized_keys /home/ansible/.ssh/authorized_keys
RUN chmod 0600 /home/ansible/.ssh/authorized_keys

STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
