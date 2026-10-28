import fcntl
import json
import os
from pathlib import Path
import subprocess
import sys


def ctl(*args):
    return subprocess.check_output(["hyprctl", *args], text=True)


runtime = Path(os.environ["XDG_RUNTIME_DIR"])
prefix = runtime / ("hypr-alt-tab-" + os.environ["HYPRLAND_INSTANCE_SIGNATURE"])
state_file = prefix.with_suffix(".json")
with prefix.with_suffix(".lock").open("w") as lock:
    fcntl.flock(lock, fcntl.LOCK_EX)
    if sys.argv[1] == "reset":
        state_file.unlink(missing_ok=True)
        sys.exit(0)

    clients = json.loads(ctl("-j", "clients"))
    clients = [c for c in clients if c["mapped"] and not c["hidden"]
               and c["workspace"]["id"] > 0
               and c["focusHistoryID"] >= 0
               and not c["title"].startswith("notificationtoasts_")]
    addresses = {c["address"] for c in clients}
    active = json.loads(ctl("-j", "activewindow")).get("address")
    try:
        state = json.loads(state_file.read_text())
    except (FileNotFoundError, ValueError):
        state = {}
    if state.get("selected") != active:
        state = {}
    order = [a for a in state.get("order", []) if a in addresses]
    if not order:
        order = [c["address"] for c in sorted(clients, key=lambda c: c["focusHistoryID"])]
    if not order:
        sys.exit(0)
    index = order.index(active) if active in order else -1
    step = -1 if sys.argv[1] == "prev" else 1
    target = order[(index + step) % len(order)]
    ctl("dispatch", "focuswindow", "address:" + target)
    state_file.write_text(json.dumps({"order": order, "selected": target}))
