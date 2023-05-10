{
  description = "Mastodon Digest";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let pkgs = import nixpkgs { inherit system; };
        deps = ps: with ps; [
          jinja2
          mastodon-py
          scipy
          python-dotenv
        ];
        python-env = pkgs.python3.withPackages (ps: deps ps);
        src = pkgs.fetchFromGitHub {
          owner = "hodgesmr";
          repo = "mastodon_digest";
          rev = "6574e63a9e319f15728278753d9632c5e7e821ee";
          hash = "sha256-wTAf+hxdE2Ki5QavDy/FMbnHcHI7FuLycf6aCrX81fA=";
        };
        pkg = pkgs.writeShellApplication {
          name = "mastodon_digest";
          runtimeInputs = [python-env];
          text = ''
            set -o allexport
            # shellcheck source=/dev/null
            source .env
            set +o allexport
            cd ${src} && python run.py "''${@}"
          '';
        };
    in {
      packages.mastodon_digest = pkg;
      defaultApp = {type = "app"; program = "${pkg}/bin/mastodon_digest";};
      devShell = pkgs.mkShell {
        buildInputs = [python-env];
      };
    }
  );
}
