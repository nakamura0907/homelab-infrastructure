# Architecture Decision Records (ADR)

このディレクトリは、homelab の設計上の重要な決定を記録する ADR を置く。
1決定 = 1ファイルとし、`NNNN-<短いタイトル>.md`(連番)で追加する。

各ADRは概ね次の構成に従う: ステータス / コンテキスト / 決定 / 代替案と却下理由 / 結果(良い点・トレードオフ)。
一度 Accepted にした決定を覆す場合は、古いADRを Superseded にして新しいADRを追加する。

## 一覧

| # | タイトル | ステータス |
|---|---|---|
| [0001](0001-secret-management.md) | シークレット管理の技術選定 (SOPS+age / env var) | Accepted |
