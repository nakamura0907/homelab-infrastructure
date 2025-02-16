import os
import sys


# 環境変数の設定（環境変数名、Terraformキー名、デフォルト値）
def get_env_vars():
    return [
        {
            "env_var": "PM_API_URL",
            "tf_key": "pm_api_url",
            "default": "https://192.168.0.200:8006/api2/json",
        },
        {
            "env_var": "PM_TLS_INSECURE",
            "tf_key": "pm_tls_insecure",
            "default": "true",
        },
        {
            "env_var": "PM_API_TOKEN_ID",
            "tf_key": "pm_api_token_id",
            "default": "terraform-prov@pve!terraform-token",
        },
        {
            "env_var": "PM_API_TOKEN_SECRET",
            "tf_key": "pm_api_token_secret",
            "default": "",
        },
        {
            "env_var": "PM_ROOTUSER",
            "tf_key": "pm_rootuser",
            "default": "root@pam",
        },
        {
            "env_var": "PM_ROOTPASSWORD",
            "tf_key": "pm_rootpassword",
            "default": "",
        },
        {
            "env_var": "CIPASSWORD",
            "tf_key": "cipassword",
            "default": "",
        },
        {
            "env_var": "OPENMEDIAVAULT_PASSTHROUGH_FILE",
            "tf_key": "openmediavault_passthrough_file",
            "default": "",
        },
        {
            "env_var": "PROXMOX_SSHKEYS",
            "tf_key": "sshkeys",
            "default": """<<EOF
<公開鍵>
EOF""",
        },
    ]


# 出力先ディレクトリおよびファイルパス
def get_output_file():
    script_dir = os.path.dirname(os.path.realpath(__file__))
    output_dir = os.path.realpath(
        os.path.join(script_dir, "../terraform/environments/homelab")
    )
    return output_dir, os.path.join(output_dir, "terraform.tfvars")


def main():
    # 環境変数リストを取得
    env_vars = get_env_vars()

    # 出力先パスを取得
    output_dir, output_file = get_output_file()

    # Terraform変数ファイル用の値を収集
    values = {}
    for var in env_vars:
        env_var = var["env_var"]
        tf_key = var["tf_key"]
        default = var["default"]

        # 環境変数の値を取得、設定されていない場合はデフォルト値を使用
        value = os.getenv(env_var, default)
        values[tf_key] = value

        # 環境変数が未設定の場合は警告を表示
        if value == default:
            print(
                f"Warning: Environment variable '{env_var}' is not set. Using default value: '{default}'"
            )

    # 出力先ディレクトリが存在するか確認
    if not os.path.exists(output_dir):
        print(
            f"Error: Output directory '{output_dir}' does not exist. Please create it manually."
        )
        sys.exit(1)

    # terraform.tfvarsファイルの内容を生成
    lines = []
    for key, value in values.items():
        if key == "sshkeys" or key == "pm_tls_insecure":
            lines.append(f"{key} = {value}")
        else:
            lines.append(f'{key} = "{value}"')
    content = "\n".join(lines) + "\n"

    # ファイルに書き込み
    try:
        with open(output_file, "w") as f:
            f.write(content)
        print(f"Successfully created '{output_file}'")
    except Exception as e:
        print(f"Error writing to file '{output_file}': {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
