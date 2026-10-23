{ pkgs }:

# One interpreter for the system, user profile, Neovim runner and debugger.
# Add shared Python dependencies here, not in separate withPackages environments.
pkgs.python3.withPackages (ps: [
  ps.pip
  ps.pygame
  ps.tkinter
  ps.debugpy
  ps.pytest
])
