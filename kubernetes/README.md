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
  --token-auth \
  --owner=$GITHUB_USER \
  --repository=homelab-infrastructure \
  --branch=<branch> \
  --path=./kubernetes/clusters/<cluster> \
  --personal
```

すでに上記コマンドを実行済みの場合は`kubectl apply`で生成されたリソースをインストールできる。

```bash
kubectl apply -k ./kubernetes/clusters/<cluster>/flux-system

# ここを改善したい
kubectl create secret generic flux-system \
  --namespace=flux-system \
  --from-literal=username="$GITHUB_USER" \
  --from-literal=password="$GITHUB_TOKEN"
```

## トラブルシューティング

### Flux CD トラブルシューティング

[Troubleshooting cheatsheet](https://fluxcd.io/flux/cheatsheets/troubleshooting/)

### Flux CDのインストールでエラーになる

以下のコマンドで状態を確認する。

```bash
flux get kustomizations --watch
flux get sources git
```

### 同じ名前空間内で同じkindがあるとすべて置き換えられてしまう

patches[].path.target.nameを指定する
