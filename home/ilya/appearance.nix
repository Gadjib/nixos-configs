{ pkgs }:

{
  scale = 1.25;

  cursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 30;
  };

  icons = {
    name = "Papirus-Dark";
    package = pkgs.papirus-icon-theme;
  };

  fonts = {
    general = {
      name = "Inter";
      size = 10;
    };
    monospace = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
  };

  gtk = {
    name = "catppuccin-macchiato-blue-standard";
    variant = "macchiato";
    accent = "blue";
    size = "standard";
  };

  kde = {
    colorScheme = "CatppuccinMacchiatoBlue";
    displayName = "Catppuccin Macchiato Blue";
    kvantumTheme = "catppuccin-macchiato-blue";
  };
}
