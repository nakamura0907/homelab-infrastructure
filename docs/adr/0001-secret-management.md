# ADR 0001: シークレット管理の技術選定

- ステータス: Accepted
- 日付: 2026-07-07
- 関連: [docs/secret-management.md](../secret-management.md), [docs/sso.md](../sso.md), [docs/pki.md](../pki.md)

## コンテキスト

homelab の秘密情報は3系統でバラバラに扱われていた。

- **Terraform**: `TF_VAR_*` 環境変数 + direnv(Git非コミット。妥当)
- **Ansible**: 環境変数lookup + `no_log`(妥当)だが、一部は**平文プレースホルダをGitにコミット**していた
  (`dns_web_password: "changeme"`、Grafana `admin_password: password`、K3s `token`)
- **Kubernetes**: `site_flux.yml` が `kubectl create secret` で**命令的**に投入(GitOps外・非バージョン管理)

かつて HashiCorp Vault 用の枠だけが残っていた(空の `terraform/vault-config/`、no-opな `vault:*` タスク、
LXC `192.168.0.212` のIP予約、docs/diagram の記述)が、実体は未構成だった。この残骸を確定扱いにせず、
**ゼロから技術選定**することにした。

制約:
- 物理ホストは1台(Intel N100 / 32GB)、単独運用。常駐サービスは増やしたくない。
- Flux CD による GitOps が中核。秘密もできる限り宣言的に扱いたい。
- **リポジトリは公開**。Gitに入るものは世界に読まれる前提。

## 決定

- **Kubernetes(Flux)層は SOPS + age** を採用する。暗号化した `*.sops.yaml` をGitにコミットし、
  Flux の kustomize-controller が `flux-system/sops-age` Secret を鍵として復号する。
- **Ansible / Terraform 層は環境変数(direnv/`.env`)** に統一する。平文プレースホルダは
  `lookup('ansible.builtin.env', ...)` へ置き換え、既存の `STEP_CA_PASSWORD` / `GITHUB_TOKEN` と同方式にする。
- **HashiCorp Vault は採用せず、残骸を撤去**する(`terraform/vault-config/`、`vault:*` タスク、
  `secret_manager` LXC(.212) と監視ターゲット、docs/diagram の記述)。
- age秘密鍵は `docs/pki.md` のCA鍵と同じく **Git外・オフライン暗号化バックアップ** で扱う。

### なぜこの切り分けか

秘密ゼロの保管・共有・バージョン管理が不要なもの(Terraform、単純なホスト秘密)は env var で十分で、
SOPSは手間が増えるだけ。一方 K8s Secret は「クラスタ内に存在」する必要があり env var では入れられず、
現状の命令的 `kubectl create secret` はGitOps外に留まる。ここにこそSOPSの価値(宣言的・履歴付き・
レビュー可能)がある。

## 代替案と却下理由

| 方式 | 却下/見送り理由 |
|---|---|
| HashiCorp Vault / OpenBAO | 常駐サーバ + unseal 運用が単独運用のN100に対して過大。可用性結合も生む |
| Sealed Secrets | 復号鍵のバックアップが別途必要でSOPSに対する優位がなく、K8s限定で3層を賄えない |
| Ansible Vault | K8s層を賄えない(3層統一不可) |
| External Secrets / Infisical 等 | バックエンドの常駐サービスが増える |
| 全面 SOPS | Terraform/単純ホスト秘密には過剰 |
| 全面 env var | K8s Secret が命令的なままGitOps外に残る |

## 結果

### 良い点
- 常駐サーバなし。N100に負荷を足さず、可用性結合も無い。
- K8s Secret が宣言的GitOpsに乗り、バージョン管理・レビュー・drift検知の対象になる。
- 守るべき鍵が **age秘密鍵1本** に集約(既存step-caの鍵運用と同型の損失時マトリクス)。
- 公開リポジトリでも平文をコミットしない状態を全層で担保。

### 注意点 / トレードオフ
- 暗号文が**公開Gitの履歴に永続**する。age秘密鍵が漏れたら全シークレットのローテーションが必要。
- 過去に平文だった値(`changeme`/`password`)は履歴から読めるため、**再暗号化ではなく新値へローテーション**する。
- `apps` Kustomization は `sops-age` Secret 先行投入が前提(順序依存)。
- 動的シークレット・監査ログ・集中管理UIは対象外。将来必要になれば OpenBAO / External Secrets へ
  段階的に拡張できる(SOPSと排他ではない)。

### スコープ
本ADRは方式選定と配線・残骸撤去まで。実際のage鍵生成・シークレットの暗号化・値のローテーションは
運用者が [docs/secret-management.md](../secret-management.md) の手順に従って実施する。
