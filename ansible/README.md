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

## トラブルシューティング

### k3s.orchestration.airgapロールでエラーが発生する

`ansible.builtin.copy`モジュールの`with_first_found`でエラーが発生する。

適切な属性を設定しているにも関わらず発生する理由は現状不明。
