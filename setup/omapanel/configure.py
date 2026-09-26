"""Apply the approved taskbar preferences after installing/enabling OmaPanel."""
import datetime
import json
import os
from pathlib import Path
import shutil

config = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "omarchy/shell.json"
state = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "omarchy-setup"
data = json.loads(config.read_text())
settings = json.loads(Path(__file__).with_name("settings.json").read_text())
state.mkdir(parents=True, exist_ok=True)
backup = state / ("shell-before-omapanel-" + datetime.datetime.now().strftime("%Y%m%d-%H%M%S-%f") + ".json")
shutil.copy2(config, backup)
for section in data["bar"]["layout"].values():
    section[:] = [entry for entry in section if entry["id"] != settings["id"]]
data["bar"]["layout"]["left"].append(settings)
data["bar"]["position"] = "bottom"
clock = None
for section in data["bar"]["layout"].values():
    for entry in section:
        if entry["id"] == "omarchy.clock":
            clock = entry
    section[:] = [entry for entry in section if entry["id"] != "omarchy.clock"]
if clock is not None:
    data["bar"]["layout"]["right"].append(clock)
config.write_text(json.dumps(data, indent=2) + "\n")
print(f"Taskbar configured. Backup: {backup}")
