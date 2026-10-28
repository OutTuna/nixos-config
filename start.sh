#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "Ошибка в строке $LINENO. Переключение не завершено; см. вывод выше." >&2' ERR

usage() {
  echo 'Использование: bash start.sh [--build-only]'
  echo 'Запускать после установки и загрузки NixOS, не из Live ISO.'
}
build_only=false
case "${1:-}" in
  '') ;;
  --build-only) build_only=true ;;
  -h|--help) usage; exit 0 ;;
  *) usage; exit 2 ;;
esac
[[ $# -le 1 ]] || { usage; exit 2; }
[[ -f /etc/NIXOS && -d /run/current-system ]] || { echo 'Нужна установленная и загруженная NixOS.' >&2; exit 1; }
[[ $EUID -ne 0 && $(id -un) == zei ]] || { echo 'Запусти от пользователя zei, без sudo. Учётную запись zei создай при установке.' >&2; exit 1; }
[[ $(uname -m) == x86_64 ]] || { echo 'Этот конфиг предназначен для x86_64.' >&2; exit 1; }
[[ -d /sys/firmware/efi && -d /boot/EFI ]] || { echo 'Ожидается UEFI-установка с ESP, смонтированным в /boot. Проверь README.' >&2; exit 1; }
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
[[ $repo != /etc/nixos && $repo != /etc/nixos/* ]] || { echo 'Клонируй репозиторий в домашний каталог, не в /etc/nixos.' >&2; exit 1; }
for cmd in nix nixos-rebuild sudo cp mktemp; do
  command -v "$cmd" >/dev/null || { echo "Не найдена команда: $cmd" >&2; exit 1; }
done
[[ -f /etc/nixos/hardware-configuration.nix ]] || { echo 'Нет /etc/nixos/hardware-configuration.nix. Сначала сгенерируй конфиг оборудования новой установки.' >&2; exit 1; }
echo 'Профиль: zei, NVIDIA RTX 5070, UEFI/systemd-boot, Hyprland + Plasma.'
echo 'Будет использована конфигурация дисков из /etc/nixos/hardware-configuration.nix.'
echo 'Пароли, личные файлы и авторизации приложений из Git не восстанавливаются.'
sudo -v
stage=$(mktemp -d /var/tmp/nixos-restore.XXXXXXXX)
trap 'rm -rf -- "$stage"' EXIT
cp -R "$repo/configuration.nix" "$repo/flake.nix" "$repo/flake.lock" "$repo/desktop" "$repo/modules" "$repo/dotfiles" "$stage/"
cp /etc/nixos/hardware-configuration.nix "$stage/hardware-configuration.nix"
# path: includes the intentionally untracked, freshly generated hardware file.
echo 'Собираю систему без переключения и без обновления flake.lock…'
sudo nixos-rebuild build --flake "path:$stage#nixos" --option experimental-features 'nix-command flakes' --no-write-lock-file
if $build_only; then
  echo 'Сборка успешна. Система и /etc/nixos не изменены.'
  exit 0
fi
read -r -p 'Сборка успешна. Сохранить /etc/nixos и применить конфиг? Введи YES: ' answer
[[ $answer == YES ]] || { echo 'Отменено, система не переключена.'; exit 0; }
backup="/etc/nixos.before-restore-$(date +%Y%m%d-%H%M%S)-$$"
sudo cp -a /etc/nixos "$backup"
# Keep the original hardware file, including any relative imports.
sudo cp -R "$stage/configuration.nix" "$stage/flake.nix" "$stage/flake.lock" "$stage/desktop" "$stage/modules" "$stage/dotfiles" /etc/nixos/
echo "Резервная копия: $backup"
sudo nixos-rebuild switch --flake path:/etc/nixos#nixos --option experimental-features 'nix-command flakes' --no-write-lock-file
echo 'Готово. Перезагрузи систему. При проблемах выбери предыдущую generation в загрузчике.'
