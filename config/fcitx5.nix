{ config, lib, pkgs, ... }:

{
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-mozc ];
  };

  environment.etc = {
    "xdg/fcitx5/profile".text = ''
      [Groups/0]
      # Group Name
      Name=Default
      # Layout
      Default Layout=us
      # Default Input Method
      DefaultIM=mozc

      [Groups/0/Items/0]
      # Name
      Name=keyboard-us
      # Layout
      Layout=

      [Groups/0/Items/1]
      # Name
      Name=mozc
      # Layout
      Layout=

      [GroupOrder]
      0=Default
    '';

    "xdg/fcitx5/config".text = ''
      [Hotkey]
      # Enumerate when press trigger key repeatedly
      EnumerateWithTriggerKeys=True
      # Temporally switch between first and current Input Method
      AltTriggerKeys=
      # Skip first input method while enumerating
      EnumerateSkipFirst=False
      # Enumerate Input Method Group Forward
      EnumerateGroupForwardKeys=
      # Enumerate Input Method Group Backward
      EnumerateGroupBackwardKeys=

      [Hotkey/TriggerKeys]
      0=Zenkaku_Hankaku
      1=Hangul

      [Hotkey/EnumerateForwardKeys]
      0=Control+Super+space

      [Hotkey/EnumerateBackwardKeys]
      0=Control+Shift+Super+space

      [Hotkey/ActivateKeys]
      0=Hangul_Hanja

      [Hotkey/DeactivateKeys]
      0=Hangul_Romaja

      [Hotkey/PrevPage]
      0=Up

      [Hotkey/NextPage]
      0=Down

      [Hotkey/PrevCandidate]
      0=Shift+Tab

      [Hotkey/NextCandidate]
      0=Tab

      [Hotkey/TogglePreedit]
      0=Control+Alt+P

      [Behavior]
      # Active By Default
      ActiveByDefault=False
      # Share Input State
      ShareInputState=No
      # Show preedit in application
      PreeditEnabledByDefault=True
      # Show Input Method Information when switch input method
      ShowInputMethodInformation=True
      # Show Input Method Information when changing focus
      showInputMethodInformationWhenFocusIn=False
      # Show compact input method information
      CompactInputMethodInformation=True
      # Show first input method information
      ShowFirstInputMethodInformation=True
      # Default page size
      DefaultPageSize=5
      # Force Enabled Addons
      EnabledAddons=
      # Force Disabled Addons
      DisabledAddons=
      # Preload input method to be used by default
      PreloadInputMethod=True
    '';

    "xdg/fcitx5/conf/clipboard.conf".text = ''
      # Trigger Key
      TriggerKey=
      # Paste Primary
      PastePrimaryKey=
      # Number of entries
      Number of entries=5
    '';

    "xdg/fcitx5/conf/notifications.conf".text = ''
      # Hidden Notifications
      HiddenNotifications=
    '';

    "xdg/fcitx5/conf/quickphrase.conf".text = ''
      # Trigger Key
      TriggerKey=
      # Choose key modifier
      Choose Modifier=None
      # Enable Spell check
      Spell=True
      # Fallback Spell check language
      FallbackSpellLanguage=en
    '';
  };
}
