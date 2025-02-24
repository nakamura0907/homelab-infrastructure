# Homelab Kubernetes

## Flux CD

初回は`flux bootstrap`コマンドを実行する。

- Flux CLIコマンドがインストール済み
- Personal access tokenが発行済み
  - リポジトリへの権限があること
    - Administration
    - Contents
- ブランチが保護されていないこと

```bash
export GITHUB_TOKEN=<token>
export GITHUB_USER=nakamura0907

flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=homelab-infrastructure \
  --branch=<branch> \
  --path=./kubernetes/clusters/<cluster> \
  --personal
```

すでに上記コマンドを実行済みの場合は`kubectl apply`で生成されたリソースをインストールできる。

```bash
kubectl apply -f ./kubernetes/clusters/<cluster>/flux-system/gotk-components.yaml
kubectl apply -f ./kubernetes/clusters/<cluster>/flux-system/gotk-sync.yaml
kubectl apply -f ./kubernetes/clusters/<cluster>/flux-system/kustomization.yaml
```
