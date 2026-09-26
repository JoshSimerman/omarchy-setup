# Additional browsers — 2026-09-22

Josh requested Firefox, Brave, Helium, and “Chromium Beta.” Stable Chromium was
already installed and selected as the default (`chromium.desktop`). No default
browser change was requested.

Firefox was installed from Arch extra using `omarchy pkg add firefox` with
graphical privilege escalation. Brave and Helium use AUR recipes that repackage
official upstream binary releases. Recipes and launcher patches were inspected
before building locally as the normal user with `makepkg --noconfirm`.

AUR recipe revisions:

- brave-bin: `1088e28a3c037f0c7f6a886fd0f93c09774db697`
- helium-browser-bin: `a5534ba8debb7685a92af74d236d82a9378eab7c`

Helium's signing key was obtained from its upstream `pubkey.asc`, fingerprint
checked against the upstream README and recipe, and imported into the user's
GPG keyring for release verification:
`BE677C1989D35EAB2C5F26C9351601AD01D6378E`.

Sources:

- https://aur.archlinux.org/packages/brave-bin
- https://aur.archlinux.org/packages/helium-browser-bin
- https://github.com/imputnet/helium-linux#signature

Recipe checkouts/build files are cached under
`~/.cache/omarchy-setup/browsers/`.

## Repeating on another machine

Install Firefox with `omarchy pkg add firefox`. For Brave and Helium, review the
current AUR recipes, import/verify Helium's upstream signing key, and use the
normal AUR helper (`omarchy pkg aur add brave-bin helium-browser-bin`) or build
with `makepkg` as a normal user followed by `sudo pacman -U` on the exact package
artifacts. Do not run makepkg as root or bypass source/signature verification.

## Undo

Close the relevant browser, then use `sudo pacman -R firefox brave-bin
helium-browser-bin` to remove these browser packages. Review dependencies before
removing any additionally installed dependency. Browser profiles are not deleted
by package removal. Stable Chromium should remain installed and retain its
original default-browser selection.

## Installed and verified

- Firefox: package 155.0.1-1; `firefox --version` succeeds.
- Brave: package 1:1.95.104-1; `brave --version` succeeds.
- Helium: package 0.17.2.1-1; `helium-browser --version` succeeds.
- Additional dependency installed: mailcap 2.1.54-3.

Brave and Helium package builds completed with recipe hash checks passing;
Helium's detached release signature passed as well. The completed package
artifacts were installed with graphical privilege escalation using `pacman -U`.
All three have installed application-menu desktop entries. Verification covered
binary startup/version reporting and launcher presence, not interactive browsing.
The default browser still reports `chromium.desktop`.

## Google Chrome Beta

Josh confirmed Google Chrome Beta as the substitute for the unavailable
Chromium Beta package. Installed `google-chrome-beta` 155.0.8059.5-1 using
AUR recipe `4475762e469db7c70492150d3662aa5fe3169607`, repackaging Google's
upstream .deb. Inspected the recipe, launcher, and install hook; SHA-512 source
checks passed. Built with makepkg as the normal user, installed the resulting
package with `pkexec pacman -U --noconfirm`.

`google-chrome-beta --version` reports Google Chrome 155.0.8059.5 beta.
Added its OmaPanel pin, preserving current pins. For another machine, review
then install using `omarchy pkg aur add google-chrome-beta` and merge the
tracked pin. To undo, remove its pin and run `sudo pacman -R google-chrome-beta`.
No stable Chromium package or profile was replaced.

## Taskbar pins

Josh also requested pinned taskbar entries. Appended Firefox, Brave, and Helium
to OmaPanel's existing `pinnedApps` JSON string in the current shell.json,
preserving Chromium, Files, Terminal, and all other bar configuration. Exact
new entries are in `taskbar-pins.json`. The shell hot-reloaded the configuration;
a screenshot confirmed the Firefox, Brave, and Helium icons in the bottom bar.
Launch commands resolve to the installed binaries. Running-window grouping was
not independently tested. Chrome Beta was appended after Josh clarified the choice.

For another machine, merge these entries into the existing OmaPanel pins, rather
than replacing the whole layout. To undo, remove only entries whose desktopId
is `firefox`, `brave-browser`, `helium`, or `google-chrome-beta`. A pre-change local backup is at
`~/.local/state/omarchy-setup/shell-before-browser-pins.json`; do not restore it
wholesale over later changes.

Chrome Beta follow-up verification: screenshot confirmed the Beta-marked Chrome
icon beside the other browser pins; default browser remained `chromium.desktop`.
Backup before that pin: `~/.local/state/omarchy-setup/shell-before-chrome-beta-pin.json`.
