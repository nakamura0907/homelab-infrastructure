"""
Dependencies:
- Python 3.9+
- diagrams package

Installation:
- sudo apt install -y python3-diagrams

Licences:
- [pi-hole/graphics](https://github.com/pi-hole/graphics/blob/master/LICENSE)
"""
from diagrams import Cluster, Diagram
from diagrams.onprem.proxmox import Pve
from diagrams.onprem.monitoring import Grafana, Prometheus
from diagrams.onprem.client import User
from diagrams.onprem.vcs import Github
from diagrams.onprem.gitops import Flux
from diagrams.generic.storage import Storage
from diagrams.custom import Custom
from urllib.request import urlretrieve

with Diagram("Homelab", show=False, direction="TB"):
    user = User("user")
    github = Github("github")

    user >> github

    with Cluster("Proxmox"):
        vm_ovm = Storage("open media vault")

        with Cluster("LXC Monitoring"):
            lxc_prometheus = Prometheus("prometheus")
            lxc_grafana = Grafana("grafana")

            lxc_prometheus << lxc_grafana
        with Cluster("VM K3s Prod Cluster", direction="LR"):
            k3s_prod_flux = Flux("flux2")
            k3s_prod_prometheus = Prometheus("prometheus")

            pihole_url = "https://raw.githubusercontent.com/pi-hole/graphics/refs/heads/master/Vortex/Vortex.png"
            pihole_icon = "diagram_pihole.png"
            urlretrieve(pihole_url, pihole_icon)
            k3s_prod_pihole = Custom("pihole", pihole_icon)
        
    user >> vm_ovm
    user >> lxc_grafana
    user >> k3s_prod_pihole

    k3s_prod_prometheus << lxc_grafana
    k3s_prod_flux >> github
