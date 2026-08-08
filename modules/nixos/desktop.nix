{ pkgs, pkgsUnstable, ... }:

let
  bitwardenPolkitPolicy = pkgs.runCommand "bitwarden-polkit-policy" { } ''
    install -Dm444 \
      ${pkgsUnstable.bitwarden-desktop}/share/polkit-1/actions/com.bitwarden.Bitwarden.policy \
      $out/share/polkit-1/actions/com.bitwarden.Bitwarden.policy
  '';
in
{
  services.xserver.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-gtk
    ];
    config.hyprland = {
      default = [
        "hyprland"
        "kde"
        "gtk"
      ];
      "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
    };
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "suspend";
  };

  security.polkit.enable = true;

  services.fprintd.enable = true;
  security.pam.services = {
    # Display-manager login cannot unlock KWallet. Hyprlock talks to fprintd
    # directly in parallel with its password-only PAM stack.
    login.fprintAuth = false;
    sddm.fprintAuth = false;
    hyprlock.fprintAuth = false;

    sudo.fprintAuth = false;
    polkit-1.fprintAuth = true;
  };

  # A Home Manager package is not searched by system polkit. Expose only
  # Bitwarden's action policy, without a second system-wide desktop entry.
  environment.systemPackages = [ bitwardenPolkitPolicy ];

  programs.dconf.enable = true;

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      inter
      font-awesome
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "Inter" "Noto Sans" ];
      serif = [ "Noto Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
