{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.pass {
  environment.systemPackages = with pkgs; lib.mkMerge [
    [ gnupg ]
    (lib.mkIf (config.programs.sway.enable) [
      pass-wayland-otp rofi-pass-wayland
    ])
    (lib.mkIf (!config.programs.sway.enable) [
      pass-otp rofi-pass
    ])
  ];

  environment.etc = lib.mkIf config.programs.sway.enable {
    "sway/config.d/pass".text = ''
      ### variables
      set $mod mod4
      set $pass ${pkgs.rofi-pass-wayland}/bin/rofi-pass

      ### applications
      bindsym $mod+backslash exec $pass
    '';
  };

  home-manager.sharedModules = [
    ({ pkgs, lib, ... }: {
      xdg.configFile = {
        "rofi-pass/config".text = ''
          _do_custom_type() {
            if [ -n "$WAYLAND_DISPLAY" ] && which wtype; then
              wtype -
            else
              xdotool type --delay $xdotool_delay --clearmodifiers --file -
            fi
          }

          typePassOrOtp () {
            checkIfPass

            case "$password" in
              'otpauth://'*)
                typed="OTP token"
                printf '%s' "$(generateOTP)" | _do_custom_type
                ;;

              *)
                typed="password"
                printf '%s' "$password" | _do_custom_type
                ;;
            esac

            if [[ $notify == "true" ]]; then
                if [[ "''${stuff[notify]}" == "false" ]]; then
                    :
                else
                    notify-send "rofi-pass" "finished typing $typed";
                fi
            elif [[ $notify == "false" ]]; then
                if [[ "''${stuff[notify]}" == "true" ]]; then
                    notify-send "rofi-pass" "finished typing $typed";
                else
                    :
                fi
            fi

            clearUp
          }

          default_do=typePassOrOtp
          clip=clipboard
        '';
      };
    })
  ];
}
