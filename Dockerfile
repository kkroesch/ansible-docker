FROM fedora:latest

RUN dnf install -y openssh-server && \
    dnf clean all

RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

COPY id_ed25519.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# Copy systemd service configuration
COPY sshd.service /etc/systemd/system/sshd.service

# Ensure systemd doesn't start unnecessary services
RUN systemctl mask \
    dev-hugepages.mount \
    sys-fs-fuse-connections.mount \
    sys-kernel-config.mount \
    sys-kernel-debug.mount \
    systemd-tmpfiles-setup.service \
    systemd-udev-trigger.service \
    systemd-udevd.service

# Enable the sshd service
RUN systemctl enable sshd.service

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]
