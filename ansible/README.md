# Homelab Ansible

## Usage

以下のコマンドでロールのインストールを行う。

```bash
$ ansible-galaxy install -r requirements.yml
```

以下のコマンドでプレイブックを実行する。

```bash
$ ansible-playbook site.yml
```

## Flux CD のブートストラップ

K3s クラスター構築後、`site_flux.yml` で Flux CD をブートストラップする（コントローラの適用・Git 認証シークレット作成・reconcile）。GitHub の認証情報が必要なため `site.yml` からは分離しており、明示的に実行する。

前提:

- コントロールノードに `kubectl` / `flux` CLI がインストール済み（Nix devshell に同梱）
- Personal access token が発行済み（リポジトリの Contents 読み取り権限）

```bash
export GITHUB_USER=<owner>
export GITHUB_TOKEN=<token>

ansible-playbook site_flux.yml
```

`GITHUB_USER` / `GITHUB_TOKEN` は `.env` + direnv で読み込む運用を想定している（`.env.sample` 参照）。prod / staging 両クラスターを対象に、各クラスターの kubeconfig を取得してブートストラップする。

## トラブルシューティング

### k3s.orchestration.airgapロールでエラーが発生する

`ansible.builtin.copy`モジュールの`with_first_found`でエラーが発生する。

適切な属性を設定しているにも関わらず発生する理由は現状不明。
