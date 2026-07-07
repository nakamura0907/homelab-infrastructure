# シークレット管理 (K8s: SOPS+age / その他: 環境変数)

homelab の秘密情報を「平文でGitに置かない」形に統一するための構成と運用手順。
**このリポジトリは公開**である前提に立ち、Gitに入るのは暗号化済みファイルのみ、age秘密鍵は
`docs/pki.md` のCA鍵と同じく **Git外・オフライン暗号化バックアップ** で扱う。

## 方式

秘密情報の消費者は3レイヤーあり、それぞれ最小コストの方式を採る。

| レイヤー | 方式 | 秘密の保管場所 |
|---|---|---|
| Kubernetes (Flux) | **SOPS + age** | 暗号化した `*.sops.yaml` をGitにコミット。Fluxが復号 |
| Ansible | 環境変数 lookup | ローカルの `.env`(direnv)。Gitには入れない |
| Terraform | 環境変数 (`TF_VAR_*`) | ローカルの `.env`(direnv)。従来どおり |

```
                 age 秘密鍵 (keys.txt / Git外・オフラインBK)
                        │
          ┌─────────────┼───────────────────────────┐
          │(site_flux.yml が投入)                    │(SOPS_AGE_KEY_FILE / direnv)
          v                                          v
  flux-system/sops-age Secret          sops CLI で *.sops.yaml を暗号化/復号
          │                                          │
          v                                          v
  Flux kustomize-controller ── 復号 ──> K8s Secret (Authelia等)

  Ansible ── lookup('env', ...) ──> DNS_WEB_PASSWORD / GRAFANA_ADMIN_PASSWORD / K3S_TOKEN
  Terraform ── TF_VAR_* ──> Proxmox APIトークン等
```

## 採用理由 / 代替案比較

「サーバーを増やさない(N100単独運用)」「GitOps(Flux)に適合」「秘密ゼロの損失時ストーリーが明快」を軸に評価した。

| 方式 | サーバー要否 | GitOps適合 | 3層横断 | 採否 |
|---|---|---|---|---|
| **SOPS + age (K8s) + env var (他)** | 不要 | ○ | ○ | **採用** |
| HashiCorp Vault / OpenBAO | 要(LXC常駐+unseal運用) | △ | ○ | 却下: 単独運用に運用コスト過大 |
| Sealed Secrets | K8s内controller | ○ | K8s限定 | 却下: 復号鍵のBKが必要でSOPSに劣後、非K8s非対応 |
| Ansible Vault | 不要 | K8s非対応 | × | 却下: K8s層を賄えない |
| External Secrets / Infisical 等 | バックエンド常駐 | ○ | ○ | 却下: 常駐サービスが増える |
| 全面 SOPS | 不要 | ○ | ○ | 見送り: Terraform/単純ホスト秘密には過剰 |
| 全面 env var | 不要 | × | ○ | 見送り: K8s SecretがGitOps外(命令的)に残る |

決定の記録は [docs/adr/0001-secret-management.md](adr/0001-secret-management.md) を参照。

### なぜ K8s だけ SOPS で、他は環境変数か

- **env varで十分な領域**: Terraform や単純なホスト秘密は、値を必要とするのがローカルCLIやapply時の一瞬だけで、保管・共有・バージョン管理が要らない。ここにSOPSを足すと手間が増えるだけ。
- **SOPSが効く領域**: K8s Secretは「クラスタ内に存在」する必要があり、env varでは入れられない。現状 `site_flux.yml` は `kubectl create secret` で**命令的**に外挿しており、GitOps外・非バージョン管理・drift検知なし。SOPSなら暗号化Secretマニフェストを他のマニフェストと同様にGit管理でき、**宣言的・履歴付き・レビュー可能**になる。

## `.sops.yaml` の設計

リポジトリ直下の `.sops.yaml` に、K8s用の暗号化ルールのみを置く。

```yaml
creation_rules:
  - path_regex: kubernetes/.*\.sops\.ya?ml$
    encrypted_regex: "^(data|stringData)$"
    age: age1...   # 公開recipient (秘密鍵ではない)
```

- `encrypted_regex` により `data`/`stringData` の **値だけ** を暗号化する。`apiVersion`/`kind`/`metadata`/キー名は平文で残るため、`git diff` でレビューできる(値は見えない)。
- `age:` は**公開**recipientなのでコミット可。

## 鍵の作成・配置 (導入時に一度だけ)

```bash
# 1. age 鍵ペアを生成 (秘密鍵は Git 外のここに置く)
age-keygen -o ~/.config/sops/age/keys.txt
#    → 標準エラーに公開鍵 age1... が表示される

# 2. .sops.yaml の REPLACE_ME を、その公開鍵で置き換える

# 3. .env に鍵ファイルパスと各シークレットを設定 (direnv が読み込む)
#    .env.example を雛形にする
SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
DNS_WEB_PASSWORD="<新しい強いパスワード>"
GRAFANA_ADMIN_PASSWORD="<新しい強いパスワード>"
```

`SOPS_AGE_KEY_FILE` はsops CLI・`site_flux.yml` の双方が参照する唯一の鍵の入口。

## Kubernetes (Flux) への配線

1. **復号鍵の投入**: `ansible/site_flux.yml` がブートストラップ時に、ローカルの `SOPS_AGE_KEY_FILE` から
   `flux-system/sops-age` Secret を作成する(キー名 `age.agekey` 固定)。既存クラスタでは
   `task ansible:run -- site_flux.yml` を流し直す。
2. **復号の有効化**: `kubernetes/clusters/{production,staging}/apps.yaml` の `apps` Kustomization に
   `decryption.provider: sops` / `secretRef.name: sops-age` を設定済み。
3. **Secretの追加手順** (`kubernetes/apps/production/authelia/secret.sops.yaml.example` を参照):

```bash
cp secret.sops.yaml.example secret.sops.yaml
# stringData に新規生成した値を記入してから暗号化
sops --encrypt --in-place kubernetes/apps/production/authelia/secret.sops.yaml
# 同ディレクトリの kustomization.yaml の resources に secret.sops.yaml を追加してコミット
```

> **適用順序の注意**: `apps` Kustomization は `sops-age` Secret が存在しないと復号でエラーになる。
> 本方式を適用する際は先に `site_flux.yml`(sops-age投入) を実行してから、暗号化Secretをコミットすること。

これにより [docs/sso.md](sso.md) が旧来Vaultに帰属させていたAuthelia secretの供給元が、このSOPS経路に置き換わる。

## Ansible / Terraform (環境変数)

平文をGitに置かず、既存の `STEP_CA_PASSWORD` / `GITHUB_TOKEN` と同じ direnv/env lookup 方式に統一した。

| 変数(env) | 参照箇所 | 事前チェック |
|---|---|---|
| `DNS_WEB_PASSWORD` | `group_vars/dns.yml` → Pi-hole `WEBPASSWORD` | `site_dns.yml` の assert |
| `GRAFANA_ADMIN_PASSWORD` | `group_vars/grafana.yml` → Grafana admin | `site_monitoring.yml` の assert |
| `K3S_TOKEN` | `group_vars/k3s_*_cluster.yml` (任意・既定コメントアウト) | — |
| `TF_VAR_*` | `terraform/proxmox/` | Terraform変数(`sensitive`) |

env未設定のまま実行すると assert で早期失敗する(空パスワードで適用されるのを防ぐ)。

## 鍵のバックアップと紛失時

`docs/pki.md` のCA鍵と同じ方針。守るべきは **age秘密鍵1本** に集約される。

| 失うもの | 影響 |
|---|---|
| age公開鍵 (recipient) | 問題なし。`.sops.yaml` にコミット済で再取得可 |
| age秘密鍵 (バックアップあり) | 復元可。`keys.txt` を復旧すれば全 `*.sops.yaml` を復号できる |
| age秘密鍵 (バックアップなし) | 復号不可。新しい鍵を生成し、全 `*.sops.yaml` を新recipientへ再暗号化(値の再入力が必要) |
| `.env` (ローカル秘密) | 各サービスの値を再設定して該当playbookを流し直す |

- `keys.txt` は **暗号化してオフラインバックアップ** する。公開リポジトリには絶対に置かない。
- 鍵が漏洩した場合は、公開履歴の暗号文は復号可能になるため **全シークレットをローテーション** する。

## 既存平文シークレットのローテーション (必須)

過去に平文 (`changeme` / `password`) が公開Gitの履歴に入っていたため、**同じ値の再利用は無意味**。
必ず新しい強い値を生成して設定し、該当サービスへ反映する。

```bash
# 例: 新値を .env に設定後、対象playbookを流し直す
task ansible:run -- site_dns.yml         # Pi-hole 管理パスワード
task ansible:run -- site_monitoring.yml  # Grafana admin パスワード
```

## 検証

```bash
# SOPS ラウンドトリップ (鍵がある時のみ復号できる)
sops -d kubernetes/apps/production/authelia/secret.sops.yaml
git show HEAD:kubernetes/apps/production/authelia/secret.sops.yaml   # 値が暗号文であること

# Flux: 復号鍵と反映確認
kubectl -n flux-system get secret sops-age
flux get kustomizations                       # apps が Ready=True
kubectl -n <ns> get secret <name>             # 復号された Secret がクラスタ内に materialize

# Ansible: env から値が解決されること / 未設定なら assert 失敗
ansible -m debug -a "var=dns_web_password" dns
task ansible:run -- site_dns.yml

# Terraform: 変更後も検証が通ること
terraform -chdir=terraform/proxmox validate
```
