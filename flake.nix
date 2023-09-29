{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, flake-utils, naersk, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        buildInputs = with pkgs; [
          xorg.libX11 
        ];
        
        pkgs = (import nixpkgs) {
          inherit system;
        };

        lib = pkgs.lib;
        
        commonEnvironment = {
          nativeBuildInputs = with pkgs; [
            pkg-config
          ];
          LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
          inherit buildInputs;
        };

        naersk' = pkgs.callPackage naersk {};

      in rec {
        # For `nix build` & `nix run`:
        defaultPackage = naersk'.buildPackage (lib.recursiveUpdate commonEnvironment {
          src = ./.;
        });

        # For `nix develop`:
        devShell = pkgs.mkShell (lib.recursiveUpdate commonEnvironment {
          shellHook = ''
            exec $SHELL
          '';
          nativeBuildInputs = with pkgs; [ rustc cargo ];
        });
      }
    );
}
