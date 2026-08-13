{
  description = "Flake for Roundtable at 32nd Annual Fall Conference on Teaching and Learning";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-texlive.url = "github:chrjabs/nixpkgs/texlive-2026";
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus/master";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-texlive,
      flake-utils-plus,
      ...
    }:
    # Builds for all possible system architectures
    flake-utils-plus.lib.eachDefaultSystem (
      system:
      let
        # Necessary to call nixpkgs below, do not remove
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              quarto = (prev.quarto.override { }).overrideAttrs (oldAttrs: {
                postPatch = (prev.postPatch or "") + ''
                  substituteInPlace bin/quarto.js \
                    --replace-fail "syntax-highlighting" "highlight-style"
                '';
              });
            })
          ];
        };
        pkgs-texlive = import nixpkgs-texlive {
          inherit system;
          config.allowUnfree = true;
        };
        # Set here so it can be included in both Quarto and R wrappers below
        R_packages = with pkgs.rPackages; [
          CTT
          dplyr
          ggplot2
          egg
          kableExtra
          knitr
          languageserver # For R LSP support in text editors/IDEs
          quarto
          renv
        ];
        # Make R and Quarto with packages above
        my_R = pkgs.rWrapper.override {
          packages = R_packages;
        };
        auto-subtitle = pkgs.python3Packages.buildPythonApplication rec {
          pname = "auto-subtitle";
          version = "unstable"; # You can replace this with a specific date or version

          src = pkgs.fetchFromGitHub {
            owner = "m1guelpf";
            repo = "auto-subtitle";
            rev = "main"; # Or pin to a specific commit hash for reproducibility
            hash = "sha256-JfZjaJ4i7uAxf7vvNA6nvKgfZK+4cLimE4wM+SAVvXw="; # See note below on how to update this
          };
          pyproject = true;
          build-system = [
            pkgs.python3Packages.setuptools
            pkgs.python3Packages.ffmpeg-python
          ];

          propagatedBuildInputs = with pkgs.python3Packages; [
            openai-whisper
            ffmpeg-python
          ];

          # This ensures ffmpeg is available in the program's PATH without
          # needing to install it globally on your system.
          makeWrapperArgs = [
            "--prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ffmpeg ]}"
          ];

          # The repo doesn't contain standard tests, so we skip the check phase
          doCheck = false;

          meta = with pkgs.lib; {
            description = "Automatically generate and embed subtitles into your videos";
            homepage = "https://github.com/m1guelpf/auto-subtitle";
            license = licenses.mit;
            mainProgram = "auto_subtitle";
          };
        };
        my_quarto = pkgs.quarto.override {
          extraRPackages = R_packages;
        };
        # Set up tex
        auto-multiple-choice = pkgs.auto-multiple-choice;
        my_tex = (pkgs-texlive.texliveFull.withPackages (_: [ auto-multiple-choice.tex ]));
        nativeBuildInputs = with pkgs; [
          # Auto subtitle
          auto-subtitle
          # Auto multiple choice
          auto-multiple-choice
          netpbm
          pdftk
          # CLI tools
          bashInteractive # For a basic shell on
          flake-checker # For ensuring flake is healthy and up-to-date
          # Custom R, Python, and Quarto tools
          my_R
          my_quarto
          # Rendering dependencies
          pandoc
          my_tex
          liberation_ttf # For FOSS fonts
        ];
      in
      {
        devShells.default = pkgs.mkShell {

          inherit nativeBuildInputs;

          shellHook =
            # bash
            ''
              echo " "
              echo -e "\e[32m----- Initialized Nix Flake Development Environment -----\e[0m"
              echo " "

              out=$(git --no-pager fetch --dry-run 2>&1)
              if [ -n "$out" ]
              then    
              echo -e "\e[31m----- Local git repo is behind Github remote or unreachable, Consider git pulling before further work ----- <<--\e[0m"
              echo " "
              while true; do
              read -p "----- Do you want to git pull? (y/n) ----- " yn
              case $yn in 
                [yY] ) 
                  echo " ";
                  git pull;
                  break;;
                [nN] ) 
                  echo " ";
                  echo -e "\e[31m----- WARNING: Editing repo without git pulling ----- <<--\e[0m";
                  exit;;
                * ) echo invalid response;;
              esac
              done
              else
              echo -e "\e[32m----- Local git repo is up to date with Github remote -----\e[0m"
              fi

              echo -e " "
              echo -e "\e[32m----- Setting git root directory, .Rprofile and fonts location -----\e[0m"
              export GIT_ROOT_DIR=$(git rev-parse --show-toplevel)
              export R_PROFILE_USER="$(echo $GIT_ROOT_DIR)/.Rprofile" 
              export OSFONTDIR=${pkgs.liberation_ttf}/share/fonts

              if [[ -f $R_PROFILE_USER  &&  -d $GIT_ROOT_DIR/renv ]]; 
              then
                echo -e " "
                echo -e "\e[32m----- .Rprofile and renv directory found -----\e[0m"
              else
                echo -e " "
                echo -e "\e[31m----- Missing .Rprofile and/or renv directory ----- <<--\e[0m"
              fi

              echo -e " "
              out="$($(flake-checker --no-telemetry --fail-mode > ./flake_check_results) echo $?)"
              if [ "$out" = 1 ]
              then
              echo -e "\e[31m----- Flake check gives warnings: ----- <<--\e[0m"
              echo -e " "
              cat ./flake_check_results
              rm -rf ./flake_check_results
              else
              echo -e "\e[32m----- Flake check gives good status -----\e[0m"
              rm -rf ./flake_check_results
              fi

              export LATEXMKRCSYS=$(echo $GIT_ROOT_DIR/.latexmkrc)

              echo -e " "
              echo -e "\e[32m----- Finished Nix Flake Development Environment Init Process -----\e[0m"
              echo -e " "
            '';
        };
      }
    );
}
