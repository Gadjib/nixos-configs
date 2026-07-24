{
  home.file.".local/bin/nix-install-package" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      repo="/home/ilya/nixos-config"
      packages_rel="home/ilya/packages/manual.nix"
      packages_file="$repo/$packages_rel"
      system_attr="$repo#nixosConfigurations.thinkpad-nix.config.system.build.toplevel"

      usage() {
        cat <<'USAGE'
      Usage:
        nix-install <pkgname> [pkgname...]

      Adds package names to home/ilya/packages/manual.nix, commits the change,
      and runs nh os switch once.

      Safety rules:
        - accepts one or more package names
        - requires a clean Git worktree before editing
        - refuses options and suspicious characters
        - validates each package against the current flake pkgs set
        - validates all packages before editing the config
        - refuses obvious duplicates in this config
        - creates a timestamped backup before editing
        - runs a dry-run system build before switching
        - rolls the config file back if dry-run fails
        - commits the package list before switching
      USAGE
      }

      die() {
        printf 'nix-install: %s\n' "$*" >&2
        exit 1
      }

      if [[ "$#" -lt 1 ]]; then
        usage
        exit 2
      fi

      [[ -d "$repo" ]] || die "repository not found: $repo"
      [[ -f "$packages_file" ]] || die "manual packages file not found: $packages_file"

      cd "$repo"

      if [[ -n "$(git status --porcelain --untracked-files=normal)" ]]; then
        git status --short >&2
        die "repository must be clean before nix-install can modify and switch the system"
      fi

      packages=("$@")
      validated=()

      for pkg in "''${packages[@]}"; do
        [[ "$pkg" == -* ]] && die "refusing option-like package name: $pkg"
        [[ "$pkg" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]*$ ]] || die "invalid package name: $pkg"
        [[ "$pkg" != *..* ]] || die "refusing package name with '..': $pkg"
        [[ "$pkg" != *.*.* ]] || die "nested package paths beyond one dot are not supported yet: $pkg"

        for seen in "''${validated[@]}"; do
          [[ "$seen" == "$pkg" ]] && die "duplicate package in command: $pkg"
        done

        existing="$(
          find "$repo" -name '*.nix' -print0 \
            | xargs -0 awk -v pkg="$pkg" 'NF == 1 && $1 == pkg { print FILENAME ":" FNR ":" $0 }'
        )"
        if [[ -n "$existing" ]]; then
          printf '%s\n' "$existing" >&2
          die "$pkg already appears as a standalone package entry"
        fi

        printf 'Checking package `%s` in current flake...\n' "$pkg"
        if ! resolved_name="$(
          nix --extra-experimental-features nix-command \
            --extra-experimental-features flakes \
            eval --raw ".#nixosConfigurations.thinkpad-nix.pkgs.$pkg.name" 2>/tmp/install-package-nix-eval.$$
        )"; then
          cat /tmp/install-package-nix-eval.$$ >&2
          rm -f /tmp/install-package-nix-eval.$$
          die "package not found in current pkgs set: $pkg"
        fi
        rm -f /tmp/install-package-nix-eval.$$
        printf 'Resolved: %s -> %s\n' "$pkg" "$resolved_name"
        validated+=("$pkg")
      done

      backup="$packages_file.backup.$(date +%Y%m%d-%H%M%S)"
      cp "$packages_file" "$backup"

      tmp="$(mktemp)"
      package_lines="$(mktemp)"
      for pkg in "''${validated[@]}"; do
        printf '    %s\n' "$pkg" >> "$package_lines"
      done

      awk -v package_lines="$package_lines" '
        /^  ];$/ && !inserted {
          while ((getline line < package_lines) > 0) {
            print line
          }
          close(package_lines)
          inserted = 1
        }
        { print }
        END {
          if (!inserted) {
            exit 42
          }
        }
      ' "$packages_file" > "$tmp" || {
        rm -f "$tmp"
        rm -f "$package_lines"
        cp "$backup" "$packages_file"
        die "could not insert package into $packages_file"
      }
      rm -f "$package_lines"
      mv "$tmp" "$packages_file"

      printf 'Added packages to %s:\n' "$packages_file"
      printf '  %s\n' "''${validated[@]}"
      printf 'Running dry-run build before switch...\n'

      if ! nix --extra-experimental-features nix-command \
        --extra-experimental-features flakes \
        build "$system_attr" --dry-run; then
        cp "$backup" "$packages_file"
        die "dry-run failed; restored $packages_file from $backup"
      fi

      expected_status=" M $packages_rel"
      actual_status="$(git status --porcelain --untracked-files=normal)"
      if [[ "$actual_status" != "$expected_status" ]]; then
        git status --short >&2
        die "repository changed unexpectedly; refusing to commit or switch"
      fi

      package_summary="''${validated[0]}"
      for pkg in "''${validated[@]:1}"; do
        package_summary+=", $pkg"
      done
      git add -- "$packages_rel"
      if ! git commit -m "Install packages: $package_summary" -- "$packages_rel"; then
        die "Git commit failed; refusing to switch"
      fi

      if [[ -n "$(git status --porcelain --untracked-files=normal)" ]]; then
        git status --short >&2
        die "repository is no longer clean after commit; refusing to switch"
      fi

      printf 'Dry-run passed and package change committed. Running nh os switch...\n'
      if ! nh os switch "$repo"; then
        die "nh os switch failed; package remains in config, backup is $backup"
      fi

      printf 'Installed packages through NixOS config:\n'
      printf '  %s\n' "''${validated[@]}"
      printf 'Backup kept at: %s\n' "$backup"
    '';
  };
}
