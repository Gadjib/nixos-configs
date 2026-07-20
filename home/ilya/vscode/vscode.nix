{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = [
        pkgs.vscode-extensions.shd101wyy.markdown-preview-enhanced
      ];
      userSettings = {
        "markdown-preview-enhanced.previewMode" = "Previews Only";
        "workbench.editorAssociations" = {
          "*.md" = "markdown-preview-enhanced";
        };
      };
    };
  };
}
