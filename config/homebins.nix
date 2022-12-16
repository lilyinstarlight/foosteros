{ config, lib, pkgs, ... }:

{
  # only for user lily
  home-manager.users.lily = { pkgs, lib, ... }: {
    home.file = {
      "bin/addr" = {
        source = lib.getExe (pkgs.writeShellApplication {
          name = "addr";
          runtimeInputs = with pkgs; [ curl ];
          text = ''
            exec curl "$@" icanhazip.com
          '';
        });
      };

      "bin/alert" = {
        source = lib.getExe (pkgs.writeShellApplication {
          name = "alert";
          runtimeInputs = with pkgs; [ curl ];
          text = ''
            exec curl -s -X POST -d body="$*" https://alert.lily.flowers/ "$@" >/dev/null
          '';
        });
      };

      "bin/genpass" = {
        source = lib.getExe (pkgs.writeShellApplication {
          name = "genpass";
          runtimeInputs = with pkgs; [ gnugrep ];
          text = ''
            grep -E '^\w{4,}$' ${pkgs.google-10000-english}/share/dict/google-10000-english-usa-no-swears.txt | sort -R | head -n4 | paste -sd ""
          '';
        });
      };

      "bin/pdflatexmk" = {
        source = lib.getExe (pkgs.writeShellApplication {
          name = "pdflatexmk";
          runtimeInputs = with pkgs; [ texlive.combined.scheme-full ];
          text = ''
            latexmk -pdf "$@" && latexmk -c "$@"
          '';
        });
      };

      "bin/ssh" = {
        source = lib.getExe (pkgs.writeShellApplication {
          name = "ssh";
          runtimeInputs = with pkgs; [ openssh ];
          text = ''
            if [ "$TERM" = alacritty ]; then
              export TERM=xterm-256color
            fi
            exec "$(which --skip-tilde ssh)" "$@"
          '';
        });
      };

      "bin/scp-nofp" = {
        source = lib.getExe (pkgs.writeShellApplication {
          name = "scp-nofp";
          runtimeInputs = with pkgs; [ openssh ];
          text = ''
            scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$@"
          '';
        });
      };

      "bin/sftp-nofp" = {
        source = lib.getExe (pkgs.writeShellApplication {
          name = "sftp-nofp";
          runtimeInputs = with pkgs; [ openssh ];
          text = ''
            sftp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$@"
          '';
        });
      };

      "bin/ssh-nofp" = {
        source = lib.getExe (pkgs.writeShellApplication {
          name = "ssh-nofp";
          runtimeInputs = with pkgs; [ openssh ];
          text = ''
            ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$@"
          '';
        });
      };
    };
  };
}