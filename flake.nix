{
  description = "A development environment for Xilinx FPGA development";

  inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
      flake-utils.url = "github:numtide/flake-utils";
      nix-xilinx.url = "gitlab:doronbehar/nix-xilinx";
  };

outputs = { self, nixpkgs, nix-xilinx, flake-utils }:
    flake-utils.lib.eachDefaultSystem

    (system:
    let
        overlays = [ nix-xilinx.overlay ];
        pkgs = import nixpkgs {
            inherit system overlays;
            config.allowUnfree = true;
        };
    in
    with pkgs; {
        devShells.default = mkShell {
            buildInputs = [
                neovim neovide
                vivado vitis
                vscode
            ];
            shellHook = nix-xilinx.shellHooksCommon + ''
                export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=gasp'
            '';
        };
    }
    );
}

