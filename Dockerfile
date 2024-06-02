FROM fedora:latest

RUN dnf install -y openssh-server procps && \
    dnf clean all

RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

COPY .ssh/id_ed25519.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# Generate SSH host keys
RUN ssh-keygen -A

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

# Ensure SSH daemon is started
CMD ["/usr/sbin/sshd", "-D"]
