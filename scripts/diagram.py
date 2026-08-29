from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.client import User
from diagrams.onprem.vcs import Github
from diagrams.onprem.certificates import LetsEncrypt, CertManager
from diagrams.onprem.dns import Coredns
from diagrams.generic.network import Router
from diagrams.onprem.network import Caddy, Traefik, Nginx
from diagrams.onprem.monitoring import Prometheus, Grafana
from diagrams.onprem.logging import Loki, FluentBit
from diagrams.generic.storage import Storage
from diagrams.onprem.gitops import Flux

graph_attr = {
    "fontsize": "14",
    "bgcolor": "white",
    "pad": "1.0",
    "nodesep": "0.5",
    "ranksep": "1.2",
}

with Diagram(
    "自宅サーバー構成図 (Proxmox — GMKtec G3 Plus)",
    filename="docs/diagram",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
):
    user = User("User")
    github = Github("GitHub")

    with Cluster("LXC .211 — step-ca"):
        step_ca = LetsEncrypt("step-ca\n内部CA / ACME")

    with Cluster("LXC .213 — DNS"):
        pihole = Router("Pi-hole")
        unbound = Router("Unbound")
        pihole >> unbound

    with Cluster("LXC .214 — Monitoring"):
        caddy = Caddy("Caddy")
        grafana = Grafana("Grafana")
        prometheus = Prometheus("Prometheus")
        caddy >> [grafana, prometheus]
        grafana >> prometheus

    with Cluster("VM — OpenMediaVault"):
        ovm = Storage("OpenMediaVault\nNAS")

    with Cluster("K3s クラスタ — MetalLB 192.168.0.230"):
        flux = Flux("Flux CD")
        traefik = Traefik("Traefik")
        cert_manager = CertManager("cert-manager")
        coredns = Coredns("CoreDNS")
        homepage = Nginx("Homepage")
        k_prom = Prometheus("Prometheus")
        loki = Loki("Loki")
        promtail = FluentBit("Promtail")

        flux >> [traefik, cert_manager, loki]
        traefik >> homepage
        cert_manager >> Edge(label="TLS証明書") >> traefik
        promtail >> loki

    # ユーザーアクセス
    user >> traefik
    user >> caddy
    user >> github

    # GitOps
    github >> Edge(label="GitOps") >> flux

    # ACME
    cert_manager >> Edge(label="ACME") >> step_ca
    caddy >> Edge(label="ACME") >> step_ca

    # 監視
    grafana >> [k_prom, loki]
    prometheus >> [ovm, pihole]

    # ログ集約
    ovm >> Edge(label="Alloy") >> loki
    pihole >> Edge(label="Alloy") >> loki
