// Run once in the new Plasma session, after the default panel exists.
var allPanels = panels();
if (allPanels.length === 0) {
    throw new Error("Waiting for Plasma's default panel");
}
for (var i = 0; i < allPanels.length; i++) {
    var panel = allPanels[i];
    panel.location = "bottom";
    panel.height = 44;
    panel.hiding = "none";
    var widgets = panel.widgets();
    for (var j = 0; j < widgets.length; j++) {
        var widget = widgets[j];
        if (widget.type === "org.kde.plasma.icontasks") {
            widget.currentConfigGroup = ["General"];
            widget.writeConfig("showToolTips", true);
            widget.writeConfig("launchers", [
                "preferred://browser",
                "applications:org.kde.dolphin.desktop",
                "applications:org.kde.konsole.desktop",
                "applications:systemsettings.desktop"
            ]);
            widget.reloadConfig();
        }
    }
}
print("omarchy-setup-panel-ready");
