# IdP/SSO 構想 (Authelia)

TLS基盤(docs/pki.md)の上に載せるSSOの見取り図。**本体のデプロイは次フェーズ**。

## 方式

IdPは **Authelia** を採用予定。

- v4.38+ でOIDC Providerを正式サポート、Traefik連携のforward-authも持つ
- Authentikより軽量(単一バイナリ+設定ファイル)で、config-as-codeのため既存のFlux GitOpsに適合
- SAMLやLDAPディレクトリ、GUI管理が必要になった場合はAuthentikを再検討する

## 認証経路

```
                        ┌──────────────────────────────┐
 User ── https ──> Traefik (192.168.0.230)             │
                        │                              │
        OIDC対応アプリ   │        OIDC非対応アプリ        │
        (Grafana等)     │        (Prometheus/Pi-hole等) │
             │          │              │               │
             v          │              v               │
        OIDC (OP) <─────┤        forwardAuth ミドルウェア │
             │          │              │               │
             └──────> Authelia (auth.home.arpa) <──────┘
                        │
                   ユーザーDB / セッションストア
```

- **OIDC対応アプリ**: Authelia をOIDC Provider(OP)として登録する(例: Grafana の `auth.generic_oauth`)
- **OIDC非対応アプリ**: Traefik の `forwardAuth` ミドルウェアで Authelia に認証を委譲する
- K3s外のサービス(Grafana等)もOIDCなら直接連携できる。forward-authで保護したい場合はTraefik経由の公開へ寄せる

## 準備済みの土台(TLS化フェーズで対応)

- `auth.home.arpa` をDNS予約済み(Traefik Ingress IP `192.168.0.230`)
- 証明書は homepage と同じ cert-manager(ClusterIssuer `step-ca`)のIngress annotationで自動発行できる
- Traefik / cert-manager / 内部CA が稼働済み

## 次フェーズの作業(未実施)

1. Autheliaのsecret類(JWT/セッション/OIDC HMAC・秘密鍵)は **SOPS+age** で暗号化した `secret.sops.yaml` をFluxが復号して供給する(→ [docs/secret-management.md](secret-management.md))
2. Authelia のデプロイ(Flux HelmRelease + Ingress `auth.home.arpa`)
3. ユーザーDB(まずはファイルベース)とセッションストア(小規模ならメモリ/SQLite、必要ならRedis)
4. OIDCクライアント登録(Grafana等)と Traefik `forwardAuth` ミドルウェアの適用
