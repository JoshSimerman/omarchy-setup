# VS Code and AI desktop apps — 2026-09-22

Josh requested VS Code, the Codex desktop app, and Claude Desktop. Used the
configured Omarchy package repository's binary packages:

| App | Package | Version |
| --- | --- | --- |
| Visual Studio Code | visual-studio-code-bin | 1.138.0-1 |
| ChatGPT desktop with Codex | openai-codex-desktop | 26.915.31945-1 |
| Claude Desktop | claude-desktop | 2.2553.1-1 |

Installation command: `omarchy pkg add visual-studio-code-bin
openai-codex-desktop claude-desktop`, run using graphical privilege escalation.
The transaction also installs `lsof` 4.99.7-1 as a dependency. No existing CLI
installations, shell aliases, default browser, or taskbar pins were replaced.

## Product availability and packaging

OpenAI's official documentation identifies the current Linux desktop product
as ChatGPT with Codex, in preview, including Arch Linux support:
https://learn.chatgpt.com/docs/linux/linux-app

Used Omarchy's existing package rather than adding another repository or running
the upstream installer, which also performs a full system upgrade.

Anthropic publishes Claude Desktop for Linux in beta. Its officially listed
Linux distributions are Ubuntu and Debian; this machine uses Omarchy's Arch
package of that app:
https://support.claude.com/en/articles/10065433-install-claude-desktop

Claude's optional Cowork virtualization packages and KVM group changes were not
included. Full Cowork setup is separate from installing the desktop application.
The user signs into the desktop apps themselves; account credentials are not
stored in this repository.

## Repeat and undo

On another Omarchy machine with these packages available, run the installation
command above. Versions may change. Updates follow the configured package
manager/repository workflow.

To remove, close the apps and run:

```bash
sudo pacman -R visual-studio-code-bin openai-codex-desktop claude-desktop
```

Review whether lsof is still needed before removing it separately. Package
removal does not delete user profiles or account data. Existing Codex and Claude
CLI installations remain independent.

## Verification

All three packages installed successfully. `code --version` reported 1.138.0.
Launched each via `uwsm-app -- code`, `uwsm-app -- chatgpt`, and
`uwsm-app -- claude-desktop`. Hyprland reported mapped windows for `code`
(Welcome - Visual Studio Code), `chatgpt` (ChatGPT), and `com.anthropic.Claude`
(Claude). App-menu entries are installed as `code.desktop`, `chatgpt.desktop`,
and `com.anthropic.Claude.desktop`. The Codex package also provides the
`codex-desktop` command alias.

Both AI apps emitted Fontconfig cache-version and Wayland/Vulkan startup
warnings but created windows successfully. No graphics workaround was applied.
Authentication and full agent/Cowork workflows were not exercised. Chromium
remains the default browser (`chromium.desktop`).
