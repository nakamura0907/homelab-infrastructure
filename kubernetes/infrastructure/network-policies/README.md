# network-policies

各 namespace の Pod 間通信を最小権限化するための `networking.k8s.io/v1` NetworkPolicy 群。
K3s 標準 CNI(Flannel + kube-router 内蔵 NetworkPolicy コントローラ)で強制されるため、追加コンポーネントは不要。

## 方針

- **default-deny は Ingress 方向のみ**。egress deny は apiserver(node IP:6443)や DNS への到達性を壊しやすいため、今回は導入しない。
- namespace の指定には K8s 1.21+ の自動ラベル `kubernetes.io/metadata.name` を使う(手動ラベル付与は不要)。
- 各ポリシーは `podSelector: {}` + ポート/送信元で絞る(chart 固有ラベルはアップグレードで壊れやすいため使わない)。
- `flux-system` と `kube-system` は対象外(前者は Flux 生成ポリシーで実質ロック済み、後者は CoreDNS 障害リスクのため)。

## 構成

```
base/<namespace>/   … namespace ごとの default-deny + 許可ポリシー
production/         … base/{metallb-system,traefik,cert-manager,homepage,logging,metrics}
staging/           … base/{metallb-system,nginx}
```

Flux からは `clusters/<cluster>/infrastructure.yaml` の `network-policies` Kustomization が
overlay(`production` / `staging`)を参照する。namespace が先に存在する必要があるため
`dependsOn` に該当 Kustomization を指定している。

## 許可ルール一覧(いずれも Ingress)

| namespace | ポリシー | 送信元 → ポート | 目的 |
|---|---|---|---|
| metallb-system | allow-webhook | `192.168.0.0/24` → 9443 | validating webhook(apiserver は node IP 発) |
| traefik | allow-entrypoints | `/24` + 全 ns → 8000, 8443 | web/websecure entrypoint |
| homepage | allow-traefik | traefik ns → 3000, 8089 | アプリ本体 + ACME HTTP-01 solver |
| logging | allow-intra-namespace | 同一 ns 全 Pod | promtail→gateway→loki |
| logging | allow-lan-gateway | `/24` → 8080 | 外部 Grafana(.214)→ Loki gateway(LB .233) |
| metrics | allow-intra-namespace | 同一 ns 全 Pod | prometheus↔alertmanager 等 |
| metrics | allow-webhook | `/24` → 10250 | prometheus-operator admission webhook |
| metrics | allow-lan-prometheus | `/24` → 9090 | 外部 Grafana(.214)→ Prometheus(LB .232) |
| cert-manager | allow-webhook | `/24` → 10250 | cert-manager webhook |
| nginx (staging) | allow-lan | `/24` → 80 | LB .161 で LAN 公開 |

`allow-metrics-scrape`(metrics ns → 各アプリの metrics ポート)は将来の ServiceMonitor 用に
metallb-system / logging / cert-manager へ用意してある(現状は非マッチでも無害)。

## kube-router 固有の注意点

- **hostNetwork Pod は NetworkPolicy 非対象**(metallb speaker, node-exporter)。node-exporter :9100 は LAN 到達可能なまま。
- **admission webhook 呼び出しは node IP 発**で届くため、`/24` からの 10250/9443 許可が必須(default-deny の典型的な落とし穴)。
- **kubelet の liveness/readiness プローブは同一 node 発**で kube-router が常に許可するため追加ルール不要。
- **kube-router はポリシーのログを出さない**。デバッグは下記の負テスト Pod と、node 上の `iptables -L KUBE-ROUTER-FORWARD` / `ipset list` で行う。

## 動作確認

```sh
# ポリシー一覧
kubectl get netpol -A

# 正常系(LAN から / staging)
curl http://192.168.0.161

# 負テスト(default ns の Pod からは拒否されること)
kubectl run curl --rm -it -n default --image=curlimages/curl -- \
  curl -m3 nginx-service.nginx
```

## ロールバック(キルスイッチ)

```sh
flux suspend kustomization network-policies -n flux-system
kubectl delete netpol -A -l app.kubernetes.io/part-of=network-policies
```

その後、該当コミットを revert する。
