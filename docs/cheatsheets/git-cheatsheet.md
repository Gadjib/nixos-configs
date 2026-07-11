# Git cheatsheet

## Basics

```bash
git status
git diff
git add path
git commit -m "message"
git log --oneline --decorate -20
git show --stat HEAD
```

## Restore

```bash
git restore path
git restore --staged path
git checkout commit -- path
git revert commit
```

## Branches

```bash
git branch
git switch -c branch
git switch main
git merge branch
```

## Stash

```bash
git stash push -m "wip"
git stash list
git stash pop
git stash drop
```

## Lazygit

```bash
lg
lazygit
```

Inside lazygit: `?` for current keybindings.

## NixOS config workflow

```bash
cd /home/ilya/nixos-config
git diff
nh os test /home/ilya/nixos-config
git add docs
git commit -m "docs: add offline system manual"
```
