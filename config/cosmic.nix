{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.cosmic {
  foosteros.profiles = {
    fonts = lib.mkDefault true;
    pipewire = lib.mkDefault true;
  };

  boot.loader.timeout = 0;

  boot.plymouth = {
    enable = true;
    theme = "nixos-bgrt";
    themePackages = [ pkgs.nixos-bgrt-plymouth ];
  };

  environment.variables = {
    NIXOS_OZONE_WL = "1";
  };

  #nix.settings = {
  #  substituters = [ "https://cosmic.cachix.org" ];
  #  trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
  #};

  services.flatpak.enable = true;

  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  environment.systemPackages = with pkgs; [
    wl-clipboard
  ];

  # only for user lily
  home-manager.users.lily = { pkgs, lib, ... }: {
    xdg.configFile = {
      # silence initial setup
      "cosmic-initial-setup-done".text = "";

      # input
      "cosmic/com.system76.CosmicComp/v1/xkb_config".text = ''
        (
            rules: "",
            model: "pc104",
            layout: "us",
            variant: "",
            options: Some("caps:escape"),
            repeat_delay: 600,
            repeat_rate: 25,
        )
      '';
      "cosmic/com.system76.CosmicComp/v1/input_touchpad".text = ''
        (
            state: Enabled,
            click_method: Some(Clickfinger),
            scroll_config: Some((
                method: Some(TwoFinger),
                natural_scroll: Some(true),
                scroll_button: None,
                scroll_factor: None,
            )),
            tap_config: Some((
                enabled: true,
                button_map: Some(LeftRightMiddle),
                drag: true,
                drag_lock: false,
            )),
        )
      '';

      # workspaces
      "cosmic/com.system76.CosmicBackground/v1/same-on-all".text = "true";
      "cosmic/com.system76.CosmicComp/v1/autotile_behavior".text = "PerWorkspace";

      # time and date
      "cosmic/com.system76.CosmicAppletTime/v1/first_day_of_week".text = "0";
      "cosmic/com.system76.CosmicAppletTime/v1/military_time".text = "true";

      # accent theme
      "cosmic/com.system76.CosmicTheme.Dark.Builder/v2/accent".text = ''
        Some((
            red: 0.9058824,
            green: 0.6117647,
            blue: 0.9960785,
        ))
      '';
      "cosmic/com.system76.CosmicTheme.Dark/v2/accent".text = ''
        (
            base: "#E79CFEFF",
            hover: "#CD91DFFF",
            pressed: "#7E598AFF",
            selected: "#CD91DFFF",
            selected_text: "#E79CFEFF",
            focus: "#E79CFEFF",
            divider: "#000000FF",
            on: "#000000FF",
            disabled: "#E79CFEFF",
            on_disabled: "#744E7FFF",
            border: "#E79CFEFF",
            disabled_border: "#E79CFE80",
        )
      '';
      "cosmic/com.system76.CosmicTheme.Dark/v2/accent_button".text = ''
        (
            base: "#E79CFEFF",
            hover: "#CD91DFFF",
            pressed: "#7E598AFF",
            selected: "#CD91DFFF",
            selected_text: "#E79CFEFF",
            focus: "#E79CFEFF",
            divider: "#030303FF",
            on: "#030303FF",
            disabled: "#E79CFEFF",
            on_disabled: "#03030380",
            border: "#E79CFEFF",
            disabled_border: "#E79CFE80",
        )
      '';
      "cosmic/com.system76.CosmicTheme.Dark/v2/background".text = ''
        (
            base: "#1B1B1BFF",
            component: (
                base: "#2E2E2EFF",
                hover: "#434343FF",
                pressed: "#585858FF",
                selected: "#434343FF",
                selected_text: "#E79CFEFF",
                focus: "#E79CFEFF",
                divider: "#C0C0C033",
                on: "#C0C0C0FF",
                disabled: "#2E2E2E80",
                on_disabled: "#C0C0C0A6",
                border: "#BEBEBEFF",
                disabled_border: "#BEBEBE80",
            ),
            divider: "#444444FF",
            on: "#E7E7E7FF",
            small_widget: "#27272740",
        )
      '';
      "cosmic/com.system76.CosmicTheme.Dark/v2/button".text = ''
        (
            base: "#9E9E9E40",
            hover: "#63636366",
            pressed: "#2B2B2B9F",
            selected: "#63636366",
            selected_text: "#E79CFEFF",
            focus: "#E79CFEFF",
            divider: "#C0C0C033",
            on: "#C0C0C0FF",
            disabled: "#9E9E9E20",
            on_disabled: "#C0C0C0A6",
            border: "#BEBEBEFF",
            disabled_border: "#BEBEBE80",
        )
      '';
      "cosmic/com.system76.CosmicTheme.Dark/v2/destructive".text = ''
        (
            base: "#FFA09AFF",
            hover: "#E0948FFF",
            pressed: "#8A5B58FF",
            selected: "#E0948FFF",
            selected_text: "#E79CFEFF",
            focus: "#E79CFEFF",
            divider: "#000000FF",
            on: "#000000FF",
            disabled: "#FFA09AFF",
            on_disabled: "#80504DFF",
            border: "#FFA09AFF",
            disabled_border: "#FFA09A80",
        )
      '';
      "cosmic/com.system76.CosmicTheme.Dark/v2/destructive_button".text = ''
        (
            base: "#FFA09AFF",
            hover: "#E0948FFF",
            pressed: "#8A5B58FF",
            selected: "#E0948FFF",
            selected_text: "#E79CFEFF",
            focus: "#E79CFEFF",
            divider: "#030303FF",
            on: "#000000FF",
            disabled: "#FFA09AFF",
            on_disabled: "#00000080",
            border: "#FFA09AFF",
            disabled_border: "#FFA09A80",
        )
      '';
      "cosmic/com.system76.CosmicTheme.Dark/v2/icon_button".text = ''
        (
            base: "#00000000",
            hover: "#63636333",
            pressed: "#16161680",
            selected: "#63636333",
            selected_text: "#E79CFEFF",
            focus: "#E79CFEFF",
            divider: "#BEBEBE33",
            on: "#BEBEBEFF",
            disabled: "#00000000",
            on_disabled: "#BEBEBEA6",
            border: "#BEBEBEFF",
            disabled_border: "#BEBEBE80",
        )
      '';
      "cosmic/com.system76.CosmicTheme.Dark/v2/link_button".text = ''
        (
            base: "#00000000",
            hover: "#00000000",
            pressed: "#00000000",
            selected: "#00000000",
            selected_text: "#E79CFEFF",
            focus: "#E79CFEFF",
            divider: "#E79CFE33",
            on: "#E79CFEFF",
            disabled: "#00000000",
            on_disabled: "#744E7F80",
            border: "#BEBEBEFF",
            disabled_border: "#BEBEBE80",
        )
      '';
      "cosmic/com.system76.CosmicTheme.Dark/v2/primary".text = ''
        (
            base: "#272727FF",
            component: (
                base: "#363636FF",
                hover: "#4A4A4AFF",
                pressed: "#5E5E5EFF",
                selected: "#4A4A4AFF",
                selected_text: "#E79CFEFF",
                focus: "#E79CFEFF",
                divider: "#FFFFFF33",
                on: "#FFFFFFFF",
                disabled: "#36363680",
                on_disabled: "#FFFFFFA6",
                border: "#BEBEBEFF",
                disabled_border: "#BEBEBE80",
            ),
            divider: "#525252FF",
            on: "#FFFFFFFF",
            small_widget: "#34343440",
        )
      '';
      "cosmic/com.system76.CosmicTheme.Dark/v2/secondary".text = ''
        (
            base: "#343434FF",
            component: (
                base: "#3B3B3BFF",
                hover: "#4F4F4FFF",
                pressed: "#626262FF",
                selected: "#4F4F4FFF",
                selected_text: "#E79CFEFF",
                focus: "#E79CFEFF",
                divider: "#D0D0D033",
                on: "#D0D0D0FF",
                disabled: "#3B3B3B80",
                on_disabled: "#D0D0D0A6",
                border: "#BEBEBEFF",
                disabled_border: "#BEBEBE80",
            ),
            divider: "#515151FF",
            on: "#C7C7C7FF",
            small_widget: "#41414140",
        )
      '';
      "cosmic/com.system76.CosmicTheme.Dark/v2/shade".text = ''
        (
            red: 0.0,
            green: 0.0,
            blue: 0.0,
            alpha: 0.32,
        )
      '';
      "cosmic/com.system76.CosmicTheme.Dark/v2/success".text = ''
        (
            base: "#5EDB8CFF",
            hover: "#5FC384FF",
            pressed: "#3A7851FF",
            selected: "#5FC384FF",
            selected_text: "#E79CFEFF",
            focus: "#E79CFEFF",
            divider: "#000000FF",
            on: "#000000FF",
            disabled: "#5EDB8CFF",
            on_disabled: "#2F6E46FF",
            border: "#5EDB8CFF",
            disabled_border: "#5EDB8C80",
        )
      '';
      "cosmic/com.system76.CosmicTheme.Dark/v2/text_button".text = ''
        (
            base: "#00000000",
            hover: "#63636333",
            pressed: "#16161680",
            selected: "#63636333",
            selected_text: "#E79CFEFF",
            focus: "#E79CFEFF",
            divider: "#E79CFE33",
            on: "#E79CFEFF",
            disabled: "#00000000",
            on_disabled: "#E79CFEA6",
            border: "#BEBEBEFF",
            disabled_border: "#BEBEBE80",
        )
      '';
      "cosmic/com.system76.CosmicTheme.Dark/v2/transparent_background".text = ''
        (
            base: "#1B1B1BC2",
            component: (
                base: "#2E2E2EC2",
                hover: "#424242C8",
                pressed: "#565656CE",
                selected: "#424242C8",
                selected_text: "#E79CFEFF",
                focus: "#E79CFEFF",
                divider: "#C0C0C033",
                on: "#C0C0C0FF",
                disabled: "#2E2E2E61",
                on_disabled: "#C0C0C0A6",
                border: "#BEBEBEFF",
                disabled_border: "#BEBEBE80",
            ),
            divider: "#434343CE",
            on: "#E7E7E7FF",
            small_widget: "#27272740",
        )
      '';
      "cosmic/com.system76.CosmicTheme.Dark/v2/transparent_primary".text = ''
        (
            base: "#272727FF",
            component: (
                base: "#363636FF",
                hover: "#363636FF",
                pressed: "#363636FF",
                selected: "#363636FF",
                selected_text: "#E79CFEFF",
                focus: "#E79CFEFF",
                divider: "#CACACA33",
                on: "#CACACAFF",
                disabled: "#36363680",
                on_disabled: "#CACACAA6",
                border: "#BEBEBEFF",
                disabled_border: "#BEBEBE80",
            ),
            divider: "#515151FF",
            on: "#F8F8F8FF",
            small_widget: "#34343440",
        )
      '';
      "cosmic/com.system76.CosmicTheme.Dark/v2/transparent_secondary".text = ''
        (
            base: "#343434FF",
            component: (
                base: "#3B3B3BFF",
                hover: "#4F4F4FFF",
                pressed: "#626262FF",
                selected: "#4F4F4FFF",
                selected_text: "#E79CFEFF",
                focus: "#E79CFEFF",
                divider: "#D0D0D033",
                on: "#D0D0D0FF",
                disabled: "#3B3B3B80",
                on_disabled: "#D0D0D0A6",
                border: "#BEBEBEFF",
                disabled_border: "#BEBEBE80",
            ),
            divider: "#515151FF",
            on: "#C7C7C7FF",
            small_widget: "#41414140",
        )
      '';
      "cosmic/com.system76.CosmicTheme.Dark/v2/warning".text = ''
        (
            base: "#FFA37DFF",
            hover: "#E09678FF",
            pressed: "#8A5C49FF",
            selected: "#E09678FF",
            selected_text: "#E79CFEFF",
            focus: "#E79CFEFF",
            divider: "#000000FF",
            on: "#000000FF",
            disabled: "#FFA37DFF",
            on_disabled: "#80523FFF",
            border: "#FFA37DFF",
            disabled_border: "#FFA37D80",
        )
      '';
      "cosmic/com.system76.CosmicTheme.Dark/v2/warning_button".text = ''
        (
            base: "#FFA37DFF",
            hover: "#E09678FF",
            pressed: "#8A5C49FF",
            selected: "#E09678FF",
            selected_text: "#E79CFEFF",
            focus: "#E79CFEFF",
            divider: "#FFFFFFFF",
            on: "#000000FF",
            disabled: "#FFA37DFF",
            on_disabled: "#00000080",
            border: "#FFA37DFF",
            disabled_border: "#FFA37D80",
        )
      '';

      # panels
      "cosmic/com.system76.CosmicPanel/v1/entries".text = ''
        [
            "Panel",
            "Dock",
        ]
      '';
      "cosmic/com.system76.CosmicPanel.Panel/v1/name".text = ''"Panel"'';
      "cosmic/com.system76.CosmicPanel.Panel/v1/anchor".text = "Top";
      "cosmic/com.system76.CosmicPanel.Panel/v1/anchor_gap".text = "false";
      "cosmic/com.system76.CosmicPanel.Panel/v1/layer".text = "Top";
      "cosmic/com.system76.CosmicPanel.Panel/v1/keyboard_interactivity".text = "OnDemand";
      "cosmic/com.system76.CosmicPanel.Panel/v1/size".text = "XS";
      "cosmic/com.system76.CosmicPanel.Panel/v1/output".text = "All";
      "cosmic/com.system76.CosmicPanel.Panel/v1/background".text = "ThemeDefault";
      "cosmic/com.system76.CosmicPanel.Panel/v1/plugins_wings".text = ''
        Some(([
            "com.system76.CosmicPanelWorkspacesButton",
            "com.system76.CosmicPanelAppButton",
        ], [
            "com.system76.CosmicAppletInputSources",
            "com.system76.CosmicAppletA11y",
            "com.system76.CosmicAppletStatusArea",
            "com.system76.CosmicAppletTiling",
            "com.system76.CosmicAppletAudio",
            "com.system76.CosmicAppletBluetooth",
            "com.system76.CosmicAppletNetwork",
            "com.system76.CosmicAppletBattery",
            "com.system76.CosmicAppletNotifications",
            "com.system76.CosmicAppletPower",
        ]))
      '';
      "cosmic/com.system76.CosmicPanel.Panel/v1/plugins_center".text = ''
        Some([
            "com.system76.CosmicAppletTime",
        ])
      '';
      "cosmic/com.system76.CosmicPanel.Panel/v1/size_wings".text = "None";
      "cosmic/com.system76.CosmicPanel.Panel/v1/size_center".text = "None";
      "cosmic/com.system76.CosmicPanel.Panel/v1/expand_to_edges".text = "true";
      "cosmic/com.system76.CosmicPanel.Panel/v1/padding".text = "0";
      "cosmic/com.system76.CosmicPanel.Panel/v1/spacing".text = "0";
      "cosmic/com.system76.CosmicPanel.Panel/v1/border_radius".text = "0";
      "cosmic/com.system76.CosmicPanel.Panel/v1/exclusive_zone".text = "true";
      "cosmic/com.system76.CosmicPanel.Panel/v1/autohide".text = "Never";
      "cosmic/com.system76.CosmicPanel.Panel/v1/autohide_behavior".text = ''
        (
            wait_time: 1000,
            transition_time: 200,
            handle_size: 4,
            unhide_delay: 200,
        )
      '';
      "cosmic/com.system76.CosmicPanel.Panel/v1/margin".text = "0";
      "cosmic/com.system76.CosmicPanel.Panel/v1/opacity".text = "1.0";
      "cosmic/com.system76.CosmicPanel.Panel/v1/autohover_delay_ms".text = "Some(500)";
      "cosmic/com.system76.CosmicPanel.Panel/v1/padding_overlap".text = "0.5";
      "cosmic/com.system76.CosmicPanel.Panel/v1/keep_style_on_maximize".text = "false";
      "cosmic/com.system76.CosmicPanel.Dock/v1/name".text = ''"Dock"'';
      "cosmic/com.system76.CosmicPanel.Dock/v1/anchor".text = "Bottom";
      "cosmic/com.system76.CosmicPanel.Dock/v1/anchor_gap".text = "false";
      "cosmic/com.system76.CosmicPanel.Dock/v1/layer".text = "Top";
      "cosmic/com.system76.CosmicPanel.Dock/v1/keyboard_interactivity".text = "OnDemand";
      "cosmic/com.system76.CosmicPanel.Dock/v1/size".text = "L";
      "cosmic/com.system76.CosmicPanel.Dock/v1/output".text = "All";
      "cosmic/com.system76.CosmicPanel.Dock/v1/background".text = "ThemeDefault";
      "cosmic/com.system76.CosmicPanel.Dock/v1/plugins_wings".text = "None";
      "cosmic/com.system76.CosmicPanel.Dock/v1/plugins_center".text = ''
        Some([
            "com.system76.CosmicPanelLauncherButton",
            "com.system76.CosmicPanelWorkspacesButton",
            "com.system76.CosmicPanelAppButton",
            "com.system76.CosmicAppList",
            "com.system76.CosmicAppletMinimize",
        ])
      '';
      "cosmic/com.system76.CosmicPanel.Dock/v1/size_wings".text = "None";
      "cosmic/com.system76.CosmicPanel.Dock/v1/size_center".text = "None";
      "cosmic/com.system76.CosmicPanel.Dock/v1/expand_to_edges".text = "false";
      "cosmic/com.system76.CosmicPanel.Dock/v1/padding".text = "4";
      "cosmic/com.system76.CosmicPanel.Dock/v1/spacing".text = "0";
      "cosmic/com.system76.CosmicPanel.Dock/v1/border_radius".text = "12";
      "cosmic/com.system76.CosmicPanel.Dock/v1/exclusive_zone".text = "false";
      "cosmic/com.system76.CosmicPanel.Dock/v1/autohide".text = "Never";
      "cosmic/com.system76.CosmicPanel.Dock/v1/autohide_behavior".text = ''
        (
            wait_time: 1000,
            transition_time: 200,
            handle_size: 4,
            unhide_delay: 200,
        )
      '';
      "cosmic/com.system76.CosmicPanel.Dock/v1/margin".text = "0";
      "cosmic/com.system76.CosmicPanel.Dock/v1/opacity".text = "1.0";
      "cosmic/com.system76.CosmicPanel.Dock/v1/autohover_delay_ms".text = "Some(500)";
      "cosmic/com.system76.CosmicPanel.Dock/v1/padding_overlap".text = "0.5";
      "cosmic/com.system76.CosmicPanel.Dock/v1/keep_style_on_maximize".text = "false";
    };
  };
}
