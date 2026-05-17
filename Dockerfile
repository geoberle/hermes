# Hermes Agent + homelab network-scanning toolkit
#
# Base image: nousresearch/hermes-agent:main pinned by multi-arch digest
# (matches what deploy/k8s/deployment.yaml currently uses).
# Bump the digest when you want a newer Hermes; rebuild this image; redeploy.
FROM nousresearch/hermes-agent@sha256:6caccd4dc14b07c9bdaa63c0b6589264c423c0ddebc195458124bc9ed0448603

# The upstream image runs its entrypoint as root and gosu-drops to UID 10000.
# We need to be root here to apt-install and to setcap on the binaries.
USER root

# Tooling rationale:
#   nmap          — primary port/host/service/OS scanner
#   ncat          — swiss-army netcat that ships with nmap (banner grabs, relays)
#   arp-scan      — fast L2 host discovery on the local segment (needs raw sockets)
#   masscan       — high-rate SYN sweeps for wide ranges (needs raw sockets)
#   tcpdump       — packet capture for debugging scans + sniffing the LAN
#   iproute2      — `ip` / `ss` so Hermes can introspect its own host-network view
#   dnsutils      — dig / nslookup for DNS recon
#   iputils-ping  — ping (the base image may not have it)
#   traceroute    — path discovery
#   ca-certificates — keep CA bundle fresh after the apt run
#
# After install we grant cap_net_raw + cap_net_admin as *file* capabilities on
# the raw-socket users so the non-root hermes user (UID 10000) can still use
# them without the container needing privileged mode. The container
# securityContext in the Deployment additionally grants NET_RAW/NET_ADMIN to
# the container itself; file caps are what actually let UID 10000 keep them.
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        nmap \
        ncat \
        arp-scan \
        masscan \
        tcpdump \
        iproute2 \
        dnsutils \
        iputils-ping \
        traceroute \
        libcap2-bin \
        ca-certificates; \
    rm -rf /var/lib/apt/lists/*; \
    setcap cap_net_raw,cap_net_admin,cap_net_bind_service+eip /usr/bin/nmap; \
    setcap cap_net_raw,cap_net_admin,cap_net_bind_service+eip /usr/bin/ncat; \
    setcap cap_net_raw,cap_net_admin+eip /usr/sbin/arp-scan; \
    setcap cap_net_raw,cap_net_admin+eip /usr/bin/masscan; \
    setcap cap_net_raw,cap_net_admin+eip /usr/bin/tcpdump; \
    setcap cap_net_raw+eip /bin/ping || setcap cap_net_raw+eip /usr/bin/ping; \
    setcap cap_net_raw+eip /usr/bin/traceroute || true

# Hand control back to the upstream entrypoint, which still starts as root
# and gosu-drops to the hermes user.
USER root
