FROM ubuntu:22.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    iproute2 iputils-ping libnss3 libnss3-tools libunbound8 \
    libevent-core-2.1-7 libevent-pthreads-2.1-7 libldns3 \
    libcurl4 libcap-ng0 libpam0g procps tcpdump libsystemd0 && \
    rm -rf /var/lib/apt/lists/*

COPY staging/usr/local/ /usr/local/

RUN mkdir -p /run/pluto /var/lib/ipsec/nss /etc/ipsec.d /var/log && \
    certutil -N -d sql:/var/lib/ipsec/nss --empty-password

CMD ["ipsec", "pluto", "--nofork", "--stderrlog"]
