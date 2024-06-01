FROM fedora:latest

RUN dnf install -y openssh-server && \
    dnf clean all

RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

COPY id_ed25519.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# Generate SSH host keys
RUN ssh-keygen -A

# Ensure SSH daemon is started
CMD ["/usr/sbin/sshd", "-D"]
