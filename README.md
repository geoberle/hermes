# hermes-image

Custom container image that extends [`nousresearch/hermes-agent`](https://hub.docker.com/r/nousresearch/hermes-agent) with a homelab network-scanning toolkit so Hermes can map and probe your LAN directly from its shell tool.

## What's added on top of upstream

| Tool        | Why |
|-------------|-----|
| `nmap`      | Primary port / host / service / OS scanner |
| `ncat`      | Banner grabs, port relays (ships with nmap) |
| `arp-scan`  | Fast L2 host discovery |
| `masscan`   | High-rate SYN sweeps |
| `tcpdump`   | Packet capture / sniffing |
| `iproute2`  | `ip` and `ss` for host-network introspection |
| `dnsutils`  | `dig`, `nslookup` |
| `iputils-ping`, `traceroute` | Reachability + path discovery |

Each binary that needs raw sockets has `cap_net_raw` / `cap_net_admin` set as **file capabilities** so the non-root `hermes` user (UID 10000) keeps them after the upstream entrypoint `gosu`-drops privileges. The Kubernetes Deployment must additionally add those capabilities to the container's `securityContext.capabilities.add`.

## Build & push

```sh
# Build for the cluster's arch (single-arch is fine; use buildx for multi)
docker build -t ghcr.io/geoberle/hermes:latest .
docker push ghcr.io/geoberle/hermes:latest
```

## Bumping upstream

Update the `FROM` digest at the top of `Dockerfile` and rebuild. The pinned digest is intentional — `:main` floats.
