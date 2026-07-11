# Git, Lazygit, Delta, gh

## Назначение

Git хранит историю NixOS-конфига, Lazygit дает TUI, Delta улучшает diff, `gh` работает с GitHub.

## Git basics

```bash
git status
git diff
git add path
git commit -m "message"
git log --oneline --decorate -20
git restore path
git switch -c branch
git switch main
git checkout old_commit -- path
```

## Ветки и stash

```bash
git branch
git switch -c docs/offline-manual
git stash push -m "wip"
git stash list
git stash pop
```

## Lazygit

```bash
lazygit
lg
```

Типовые клавиши: arrows/jk navigation, `space` stage, `c` commit, `p` pull/push context-dependent, `q` back/quit. VERIFY: точные бинды смотрите внутри lazygit через `?`, потому что они зависят от версии.

## Delta

Delta включен в Home Manager:

```nix
programs.delta.enable = true;
enableGitIntegration = true;
side-by-side = true;
```

Используйте обычный `git diff`; delta будет pager/diff renderer.

## gh

```bash
gh auth status
gh auth login
gh repo view
gh pr list
gh pr create
gh pr checkout NUMBER
```

## Workflow для nixos-config

```bash
cd /home/ilya/nixos-config
git status
git diff
nh os test /home/ilya/nixos-config
git add .
git commit -m "docs: update offline manual"
```

## Откат неудачных изменений

```bash
git diff
git restore path
git restore --staged path
git log --oneline
git revert commit
```

Избегайте `git reset --hard`, пока не уверены, что все несохраненные изменения можно потерять.

## Cheatsheet

```bash
git status
git diff
git add path
git commit -m "msg"
git restore path
lg
gh auth status
```
