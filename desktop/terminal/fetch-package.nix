{ pkgs, ... }:

# Presentation-only adaptation of Frost-Phoenix's fastfetch layout to native
# areofyl/fetch 2.3.0. Collection, live stats, input handling and 3D stay native.
# Exact replacements intentionally fail the build if upstream changes.
pkgs.fetch.overrideAttrs (old: {
  postPatch = (old.postPatch or "") + ''
    ${pkgs.python3}/bin/python3 - <<'PY'
    from pathlib import Path

    path = Path("fetch.c")
    source = path.read_text()

    def replace(old, new):
        global source
        if source.count(old) != 1:
            raise SystemExit("fetch theme patch: expected one match: " + old)
        source = source.replace(old, new)

    replace(
        '  char line[MAX_LINE_LEN];\n  snprintf(line, sizeof(line), "\\033[1;%sm%s\\033[0m: %s", label_color, label,\n           val);',
        r"""  const char *key = label;
      const char *color = label_color;
      switch (current_field) {
      case F_OS:       key = " Distro";  color = "33"; break;
      case F_KERNEL:   key = "  ├─";     color = "33"; break;
      case F_PACKAGES: key = "  ├─󰏖";     color = "33"; break;
      case F_SHELL:    key = "  └─";     color = "33"; break;
      case F_WM:       key = " DE/WM";   color = "34"; break;
      case F_THEME:    key = "  ├─󰉼";     color = "34"; break;
      case F_ICONS:    key = "  ├─󰉋";     color = "34"; break;
      case F_CURSOR:   key = "  ├─󰳽";     color = "34"; break;
      case F_FONT:     key = "  ├─";     color = "34"; break;
      case F_TERMINAL: key = "  └─";     color = "34"; break;
      case F_HOST:     key = "󰌢 System";  color = "32"; break;
      case F_DISPLAY:  key = "  ├─󰹑";     color = "32"; break;
      case F_CPU:      key = "  ├─";     color = "32"; break;
      case F_GPU:      key = "  ├─";     color = "32"; break;
      case F_MEMORY:   key = "  ├─󰘚";     color = "32"; break;
      case F_DISK:     key = "  ├─󰋊";     color = "32"; break;
      case F_UPTIME:   key = "  └─󰔚";     color = "32"; break;
      default: break;
      }
      char line[MAX_LINE_LEN];
      snprintf(line, sizeof(line), "\033[1;%sm%s\033[0m 󰑃  %s", color, key, val);""")

    replace('label_color, user, label_color, host);', '"35", user, "36", host);')
    replace('        current_field = id;', """        if (id == F_WM || id == F_HOST || id == F_COLORS)
              add_line("");
            current_field = id;""")
    replace(
        '    if (type[0])\n      add_info("GPU", "%s [%s]", name, type);',
        r"""    // PCI names put the chip first: GB205 [GeForce RTX 5070].
        // Show the product first, retaining the GPU type suffix.
        char *product = strstr(name, " [GeForce ");
        char *product_end = product ? strchr(product + 2, ']') : NULL;
        if (product && product_end &&
            (!strcmp(driver, "nvidia") || !strcmp(driver, "nouveau"))) {
          add_info("GPU", "%.*s [%.*s]%s%s%s",
                   (int)(product_end - product - 2), product + 2,
                   (int)(product - name), name,
                   type[0] ? " [" : "", type, type[0] ? "]" : "");
          continue;
        }
        if (type[0])
          add_info("GPU", "%s [%s]", name, type);""")
    path.write_text(source)
    PY
  '';
})
