{ config, lib, pkgs, ... }:

let
  initialSettings = (pkgs.formats.json { }).generate "vscode-initial-settings" {
    "markdown-preview-enhanced.previewMode" = "Previews Only";
    "workbench.editorAssociations" = {
      "*.md" = "markdown-preview-enhanced";
    };
  };
in {
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = [
        pkgs.vscode-extensions.shd101wyy.markdown-preview-enhanced
      ];
    };
  };

  # VS Code and extensions need to write settings (including JSONC comments).
  # Seed once, after Home Manager removes the previous store-backed symlink.
  home.activation.seedVscodeSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    vscodeSettings=${lib.escapeShellArg "${config.xdg.configHome}/Code/User/settings.json"}
    if [ ! -e "$vscodeSettings" ] && [ ! -L "$vscodeSettings" ]; then
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -Dm600 \
        ${initialSettings} "$vscodeSettings"
    fi
  '';
}
