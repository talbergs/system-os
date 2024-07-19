{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    webtools.url = "/mnt/c/MT/system-web";
    webtools.inputs.nixpkgs.follows = "nixpkgs";
    dbtools.url = "/mnt/c/MT/system-db";
    dbtools.inputs.nixpkgs.follows = "nixpkgs";
    editor.url = "/mnt/c/MT/talbergs/editor";
    editor.inputs.nixpkgs.follows = "nixpkgs";
    shell.url = "/mnt/c/MT/talbergs/shell";
    shell.inputs.nixpkgs.follows = "nixpkgs";
    base.url = "/mnt/c/MT/talbergs/base";
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
                environment.systemPackages = with pkgs; [
                  self.inputs.webtools.packages.${system}.default
                  self.inputs.dbtools.packages.${system}.default
                  self.inputs.shell.packages.${system}.default
                  self.inputs.editor.packages.${system}.default
                  self.inputs.base.packages.${system}.default
                ];
              }
            )
          ];
        };
      };
    };
}
