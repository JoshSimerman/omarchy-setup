# Grok and Kimi CLIs — 2026-09-22

Josh requested both CLIs. Use the official vendors' coding CLIs, not similarly
named community clients.

## Grok

An existing `~/.local/bin/grok` wrapper installs/activates the official
`npm:@xai-official/grok` package through mise, then executes it. Running the
wrapper verified Grok 1.0.41 (`4220f3b224a6`); `grok --help` identifies Grok Build
TUI. Mise reports the active installation at
`~/.local/share/mise/installs/npm-xai-official-grok/1.0.41` and the global mise
configuration at `~/.config/mise/config.toml`. The existing wrapper was retained.

Launch from your project folder with `grok`. Authentication is handled by the
CLI when the user launches it; no account credentials were accessed or stored
in this repository.

For a new machine with mise, install with
`mise use -g "npm:@xai-official/grok"`. Upstream also documents an official
installer: https://docs.x.ai/build/overview

## Kimi Code

Installed the official native Linux x64 Kimi Code CLI using the global-channel
installer from `https://code.kimi.ai/kimi-code/install.sh`. The installer was
downloaded and inspected before execution. The global script differs from the
linked kimi.com script only in download-domain references; it selects the
global login region rather than mainland China.

Installer cache: `~/.cache/omarchy-setup/cli-installers/kimi-global-install.sh`.
Installer SHA-256:
`cb166061b79c0aebff70732ddc781a0beeed080c4a49cd542fee315b4a83ae2a`.

Installation uses `KIMI_NO_MODIFY_PATH=1 bash <downloaded-script>` to preserve
existing shell startup files. A symlink from `~/.local/bin/kimi` to
`~/.kimi-code/bin/kimi` makes it available on the already configured PATH.
The installer checks the downloaded binary's SHA-256 against its release
manifest. Documentation: https://moonshotai.github.io/kimi-code/

For another machine, review the current global installer and run it the same
way, then create the symlink only if there is no existing `kimi` command to
preserve. Launch with `kimi` from a project folder and complete login yourself.

## Undo

Kimi: remove only the created `~/.local/bin/kimi` symlink and
`~/.kimi-code/bin/kimi` executable. Preserve account/configuration/session data
under `~/.kimi-code` unless separately choosing to delete it.

Grok predated this task. To intentionally remove it later, first remove its mise
global tool entry with `mise unuse -g "npm:@xai-official/grok"`, uninstall the
corresponding mise tool version, and remove the old `~/.local/bin/grok` wrapper;
otherwise invoking that wrapper would install it again. Preserve Grok's user
data separately. No permission-bypass settings or aliases were added.

## Verification

Kimi installed successfully as version 2.0.2 and passed the installer's checksum
verification. `kimi --version` and `kimi --help` succeeded; its initial region
marker is `global`. A fresh interactive Bash shell resolves both `kimi` and
`grok` without shell startup edits. In interactive Bash, mise's installed Grok
binary can take precedence over the fallback wrapper. Grok's version/help checks
also passed. Authentication and actual model requests were not exercised.
