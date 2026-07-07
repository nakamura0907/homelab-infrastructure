{
  description = "homelab development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { 
            inherit system; 
            config.allowUnfree = true; 
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            python3
            terraform
            kubectl kubernetes-helm fluxcd
            ansible
            gnutar
            go-task
            sops age
          ];
          shellHook = ''
            echo "🏠 Homelab dev environment loaded!"
            echo "Available tools: python3, terraform, kubectl, helm, fluxcd, ansible, go-task, sops, age"
          '';
        };
      });
}
