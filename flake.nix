{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    webtools.url = "/home/nixos/MT/repos/talbergs/system-web";
    webtools.inputs.nixpkgs.follows = "nixpkgs";
    dbtools.url = "/home/nixos/MT/repos/talbergs/system-db";
    dbtools.inputs.nixpkgs.follows = "nixpkgs";
    editor.url = "/home/nixos/MT/repos/talbergs/editor";
    editor.inputs.nixpkgs.follows = "nixpkgs";
    shell.url = "/home/nixos/MT/repos/talbergs/shell";
    shell.inputs.nixpkgs.follows = "nixpkgs";
    base.url = "/home/nixos/MT/repos/talbergs/base";
    base.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      ...
    }:
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nixos-wsl.nixosModules.default
            {
              system.stateVersion = "23.11";
              wsl.enable = true;
              wsl.defaultUser = "nixos";
            }

            # { programs.ssh.startAgent = true; }

            # ./module-httpd-service-new.nix

            (
              { pkgs, ... }:
              {
                nix = {
                  settings = {
                    auto-optimise-store = true;
                  };
                  gc = {
                    automatic = true;
                    dates = "weekly";
                    options = "--delete-older-than 2d";
                  };
                  registry.nixpkgs.flake = nixpkgs;
                  extraOptions = ''
                    experimental-features = nix-command flakes
                    keep-outputs          = true
                    keep-derivations      = true
                  '';
                };
                nixpkgs.config.allowUnfree = true;
              }
            )

            (
              { pkgs, ... }:
              {
                environment.variables = {
                  NIXPKGS_ALLOW_UNFREE = 1;
                };
                environment.systemPackages = with pkgs; [
                  self.inputs.webtools.packages.${system}.default
                  self.inputs.dbtools.packages.${system}.default
                  self.inputs.shell.packages.${system}.default
                  self.inputs.editor.packages.${system}.default
                  self.inputs.base.packages.${system}.default
                  nginx
                  zabbix.agent
                ];
              }
            )
          ];
        };
      };
    };
}
