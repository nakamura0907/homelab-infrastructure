# 内部PKI (step-ca) とTLS化

自宅サーバ全体をTLS化するための内部CA(step-ca)の構成と運用手順。
ドメインは取得せず `home.arpa`(RFC 8375)で完結させる。最終目標であるIdP/SSO(Authelia想定)の前提基盤。

## 構成

```
step-ca (LXC 192.168.0.211 / ca.home.arpa)
  ├── :443 ACME directory  (https://ca.home.arpa/acme/acme/directory)
  ├── :80  ルートCA配布     (http://ca.home.arpa/root_ca.crt ← 平文HTTP)
  │
  ├── ACME (HTTP-01) ──> cert-manager ──> Traefik Ingress (K3s, MetalLB 192.168.0.230)
  │                          └── homepage.home.arpa / (将来) auth.home.arpa
  ├── ACME (HTTP-01) ──> Caddy (monitoring LXC .214)
  │                          └── grafana.home.arpa / prometheus.home.arpa
  ├── ACME (HTTP-01) ──> Caddy (DNS LXC .213, Docker)
  │                          └── pihole.home.arpa
  └── ACME (HTTP-01) ──> Proxmox 組込ACME / acme.sh (OMV)
```

- ルートCA/中間CAの秘密鍵は step-ca LXC 内(`/etc/step-ca`)にのみ存在する。**リポジトリには絶対にコミットしない**
- ACMEアカウント鍵・サーバ証明書鍵は各クライアント(cert-manager/Caddy等)が自動生成・保管する
- TLS対象はユーザー向けWeb UI/APIのみ。exporter類(:9100等)の内部メトリクスは対象外

## 前提条件: home.arpa の名前解決

HTTP-01チャレンジでは **step-ca自身が対象FQDNを解決して検証しに行く**。また cert-manager も発行前のセルフチェックで解決する。
よって以下のホストが `home.arpa` を解決できる必要がある(DNS LXC `192.168.0.213` を参照すること):

- step-ca LXC(Terraformで `192.168.0.213 192.168.0.1` を設定済み)
- **K3s の CoreDNS**(cert-manager Pod はクラスタDNS経由で解決する)。K3sノードの resolver は既定でルータのため
  `home.arpa` を解決できない。`kubernetes/infrastructure/coredns-custom/` の `coredns-custom` ConfigMap が
  `home.arpa` を Pi-hole(`.213`)へ転送して解決可能にする(これが無いと ClusterIssuer が `no such host` で失敗する)。
- ACMEクライアントを動かす各ホスト(`ca.home.arpa` は site_pki.yml が /etc/hosts に固定するため耐障害性あり)

### 複数nameserver指定時の挙動(Linux)

`nameserver` を複数指定した場合、glibc resolverは**常に1番目から問い合わせ、タイムアウト時のみ2番目**を使う(優先+フォールバック)。

- DNS LXCが落ちている間: 外部名はルーター経由で解決できるが、`home.arpa` はルーターがNXDOMAINを返すため解決不可(縮退運転)。
  証明書の自動更新はその間失敗するが、ACMEクライアントはリトライするため復旧後に自動回復する
- クライアント端末(PC/スマホ)へのDHCP配布は **DNS LXCのみ**にすること。
  複数配るとOSが「同等」として扱い、home.arpa解決が不安定になり広告ブロックもすり抜ける

## 適用手順

```bash
# 1. step-ca用LXCを作成
task terraform:proxmox:apply

# 2. CAパスワードを設定(.envに追記。紛失しないこと)
#    STEP_CA_PASSWORD="<強力なパスワード>"

# 3. CA構築 + 全管理ホストへルートCA配布 + cluster-issuer-vars ConfigMap投入
#    (ルートCAはconfigmap経由でFluxがcaBundleへ注入するため、コミットは不要)
task ansible:run -- site_pki.yml

# 4. DNSレコード反映(ca/pihole/grafana/homepage等) + Pi-hole管理UIのTLS終端
task ansible:run -- site_dns.yml

# 5. Grafana/Prometheus前段のTLS終端
task ansible:run -- site_monitoring.yml

# 6. Fluxが cert-manager / traefik / homepage Ingress を反映するのを確認
flux get kustomizations
kubectl get certificate -A
```

> **ルートCAのcaBundle注入について**
> ClusterIssuerの `caBundle` はGitに固定のプレースホルダ `${ROOT_CA_B64}` だけを置き、
> 実値は site_pki.yml が作成する `flux-system/cluster-issuer-vars` ConfigMap から
> Flux(`postBuild.substituteFrom`)が注入する。ルートCAは公開情報なのでConfigMapで扱える。
> 環境固有・再生成される値をGit外に保つため、**CA再構築時も site_pki.yml を流し直すだけでコミット不要**。
> ConfigMap投入前はcert-manager-issuers Kustomizationが解決失敗しリトライするが、投入後に自動収束する。

## ルートCA証明書のクライアント配布

自己署名警告を消すには各端末の信頼ストアへルートCA(`root_ca.crt`)を導入する。
配布元は常にCAサーバ自身(紛失しても再取得できる):

```bash
# 最も簡単(スマホ等はブラウザでこのURLを開くだけ)。site_pki.ymlが :80 で配布する
#   http://ca.home.arpa/root_ca.crt
# 平文HTTPなのは、初回はまだルートを信頼しておらずHTTPSだと鶏と卵になるため。
# 公開情報だが、取得後にフィンガープリント照合を推奨。

# 定石(フィンガープリント検証付き)。fingerprintはsite_pki.yml実行時に表示される
step ca bootstrap --ca-url https://ca.home.arpa --fingerprint <FINGERPRINT>
step ca root root_ca.crt

# または
scp root@192.168.0.211:/etc/step-ca/certs/root_ca.crt .
```

- **macOS**: キーチェーンアクセスに読み込み → 「常に信頼」
- **Windows**: 証明書ストア「信頼されたルート証明機関」へインポート
- **Linux**: `/usr/local/share/ca-certificates/` に配置して `update-ca-certificates`
- **iOS/iPadOS**: プロファイルとしてインストール後、**設定 → 一般 → 情報 → 証明書信頼設定 で当該ルートをON**(忘れると信頼されない)
- **Android**: 設定 → セキュリティ → 「CA証明書」としてインストール。
  ※ Android 7+ はアプリがユーザー導入CAを既定で信頼しないが、ブラウザからのWeb UIアクセスは信頼される

スマホは `http://ca.home.arpa/root_ca.crt` をブラウザで開いて取得するのが最も簡単。
- **iOS**: プロファイルとしてインストール後、必ず **証明書信頼設定でON**にする
- **Android**: 「CA証明書」としてインストール(ブラウザからのアクセスは信頼される)

## Proxmox / OpenMediaVault (手動)

- **Proxmox**: PVEホストにルートCAを導入(`update-ca-certificates`)後、
  Datacenter → ACME でカスタムディレクトリ `https://ca.home.arpa/acme/acme/directory` を登録し、
  ノードの証明書からACME証明書(`proxmox.home.arpa`)を発注する(standalone/HTTP-01。:80は空いている)
- **OMV**: Web UIが:80を使うためstandaloneは不可。`acme.sh` のwebrootモード+deploy-hookで導入する

## CA鍵のバックアップと紛失時

| 失うもの | 影響 |
|---|---|
| 公開 `root_ca.crt` | 問題なし。CAサーバからいつでも再取得できる |
| CA秘密鍵(バックアップなし) | 復元不可。CA再構築+**全端末への再配布**+全証明書再発行 |

- `/etc/step-ca` 一式(鍵+パスワード)を**暗号化してオフラインバックアップ**すること。公開リポジトリには絶対に置かない
- STEP_CA_PASSWORD も同様に保管する(systemd起動時の鍵復号に必要)

## 検証

```bash
# CA死活・発行
step ca health --ca-url https://ca.home.arpa --root root_ca.crt

# DNS(home.arpaが外部へ漏れないことも確認)
dig homepage.home.arpa @192.168.0.213

# K3s
kubectl get certificate -A          # すべて Ready=True
curl --cacert root_ca.crt https://homepage.home.arpa

# LXC/VM
openssl s_client -connect grafana.home.arpa:443 < /dev/null | openssl x509 -noout -issuer -ext subjectAltName

# 自動更新(強制更新で経路確認)
cmctl renew -n homepage homepage-tls
```

証明書の失効前アラートはPrometheus(blackbox_exporter)の `TLSCertificateExpiringSoon` で検知する(14日前)。
