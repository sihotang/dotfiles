#!/usr/bin/env bash
chezmoi add ~
chezmoi apply
git add .
git commit -m "Update dotfiles"
git push
