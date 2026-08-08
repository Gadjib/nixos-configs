{ pkgs, lib, ... }:

{
  # Keep Codex configuration declarative while leaving the live file writable:
  # Codex stores small UI-state updates in config.toml at runtime.
  home.file.".codex/.home-manager-config.toml".text = ''
    model = "gpt-5.6-sol"
    model_reasoning_effort = "medium"
    approval_policy = "never"
    default_permissions = "workspace-full"

    [permissions.workspace-full]
    description = "Full access to the active workspace and temporary files; read-only elsewhere."

    [permissions.workspace-full.filesystem]
    ":root" = "read"
    ":slash_tmp" = "write"
    ":tmpdir" = "write"

    [permissions.workspace-full.filesystem.":workspace_roots"]
    "." = "write"
    ".git" = "write"

    [permissions.workspace-full.network]
    enabled = true
    allow_local_binding = true

    [permissions.workspace-full.network.domains]
    "*" = "allow"

    [permissions.workspace-full.network.unix_sockets]
    "/run/user/1000/bus" = "allow"
    "/home/ilya/.bitwarden-ssh-agent.sock" = "allow"

    [mcp_servers.nix]
    command = "${pkgs.mcp-nixos}/bin/mcp-nixos"
    enabled = true
    startup_timeout_sec = 30
    tool_timeout_sec = 60
    default_tools_approval_mode = "approve"

    [projects."/home/ilya/nixos-config"]
    trust_level = "trusted"

    [projects."/mnt/home/Documents/С ноута Бори"]
    trust_level = "trusted"

    [projects."/home/ilya"]
    trust_level = "trusted"

    [projects."/home/ilya/Courses/Postavy-8-inf"]
    trust_level = "trusted"

    [projects."/home/ilya/Vetraz"]
    trust_level = "trusted"

    [projects."/home/ilya/Pictures/Mayoneese"]
    trust_level = "trusted"

    [projects."/home/ilya/Games"]
    trust_level = "trusted"

    [projects."/home/ilya/Games/Colin McRae - DiRT 2 (1.1.0)"]
    trust_level = "trusted"

    [projects."/home/ilya/Documents/Postavy-26-Skit-8"]
    trust_level = "trusted"

    [notice]
    hide_rate_limit_model_nudge = true
  '';

  home.activation.installWritableCodexConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -Dm600 \
      "$HOME/.codex/.home-manager-config.toml" \
      "$HOME/.codex/config.toml"
  '';
}
