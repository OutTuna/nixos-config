{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix      # Подключаем диски и железо
    ./../../modules/core              # Подключаем основные модули FrostPhoenix
  ];
}
