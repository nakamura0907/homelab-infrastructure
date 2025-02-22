# Homelab Terraform

## Usage

`terraform.tfvars`ファイルを作成する。
生成後、必要に応じて値を編集する。

```bash
$ python3 ./generate_tfvars.py
```

対象のディレクトリに移動してリソースの作成を行う。

```bash
$ cd ./terraform/environments/homelab
$ terraform init
$ terraform plan --var-file=./terraform.tfvars
$ terraform apply --var-file=./terraform.tfvars
```

## トラブルシューティング
