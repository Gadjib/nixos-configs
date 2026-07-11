# Dev tools

## Назначение

Локальные dev-инструменты: C/C++, Node, Python, Go, Rust, direnv/nix-direnv и devShell.

## Установлено

System packages: `gcc`, `gnumake`, `cmake`, `pkg-config`, `nodejs`, `python3`, `uv`, `go`, `rustup`.

Home packages: `direnv`, `nix-direnv`.

## Общий принцип NixOS

Не ставьте глобально мусор без причины. Для проектов используйте:

- `nix shell nixpkgs#pkg` для one-off;
- `devShell` в flake;
- `direnv` + `nix-direnv`;
- project-local package managers (`uv`, `cargo`, `go`, `npm`) внутри проекта.

## C project

```bash
mkdir c-demo && cd c-demo
cat > main.c
gcc main.c -o main
./main
```

Для зависимостей используйте `pkg-config` и devShell.

## Python with uv

```bash
uv init py-demo
cd py-demo
uv run python --version
uv add requests
uv run python main.py
```

## Rust

```bash
cargo new rust-demo
cd rust-demo
cargo run
cargo test
```

Если rustup требует toolchain, ставьте осознанно или используйте Nix devShell.

## Go

```bash
go mod init example.com/demo
go run .
go test ./...
```

## Node

```bash
npm init -y
npm install
npm run dev
```

Не используйте `npm -g`, если пакет можно запускать через `nix shell`, `nix run` или project-local dependency.

## direnv/nix-direnv

```bash
echo "use flake" > .envrc
direnv allow
```

Пример `flake.nix` devShell:

```nix
{
  outputs = { nixpkgs, ... }: {
    devShells.x86_64-linux.default =
      nixpkgs.legacyPackages.x86_64-linux.mkShell {
        packages = with nixpkgs.legacyPackages.x86_64-linux; [ gcc pkg-config ];
      };
  };
}
```

## Troubleshooting

```bash
command -v gcc make cmake pkg-config node npm python3 uv go rustup cargo direnv
direnv status
nix develop
nix shell nixpkgs#pkg
```

## Cheatsheet

```bash
nix shell nixpkgs#pkg
nix develop
direnv allow
uv init
cargo new app
go mod init module
npm init -y
```
