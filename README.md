```bash
nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#git nixpkgs#gh
gh auth login
gh auth setup-git
git clone https://github.com/OutTuna/nixos-config.git ~/nixos-restore
cd ~/nixos-restore
bash start.sh
```
