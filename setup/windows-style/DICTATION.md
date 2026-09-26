# Dictation (voxtype)

Omarchy ships voxtype (`voxtype-bin` 1.0.1) as a user service
(`voxtype.service`). Josh finds it very accurate (punctuation, sentences) and
asked for live text like Windows voice typing, where words appear while
speaking.

## Shortcuts

| Keys | Action |
| --- | --- |
| Win+H | Dictation on/off (added in `windows_style.lua`) |
| Win+Ctrl+X | Dictation on/off (Omarchy default) |
| Hold F9 | Push-to-talk (Omarchy default). **Avoid with live text**; see below |

## Live text (streaming)

Changed from Whisper `base.en` (types everything after you stop) to
NVIDIA Parakeet in streaming mode (types as you speak).

1. Only `parakeet-unified-en-0.6b` supports streaming ("cache-aware",
   English-only). voxtype downloads it from the community Hugging Face repo
   `bobNight/parakeet-unified-en-0.6b-onnx` (CC-BY-4.0, model data only, no
   code). voxtype's manifest takes the full-precision files, **2.4 GB** in
   `~/.local/share/voxtype/models/parakeet-unified-en-0.6b/`; the repo's
   int8 files are not used. Downloaded with the ONNX build, because the
   Whisper build refuses Parakeet models:
   `/usr/lib/voxtype/voxtype-onnx-avx2 setup --download --model parakeet-unified-en-0.6b --no-post-install`.
2. Switched the binary: `pkexec voxtype setup onnx --enable` repoints
   `/usr/bin/voxtype` from `voxtype-avx2` to `voxtype-onnx-avx2` (both are in
   the package). The symlink itself belongs to no package; the package's
   install script manages it and on upgrade keeps the active backend
   (`_preserve_or_set_backend` in `post_upgrade`, checked 2026-09-25 against
   voxtype-bin 1.0.0). To check after an update:
   `readlink -f /usr/bin/voxtype` should end in `voxtype-onnx-avx2`. If not,
   re-run `pkexec voxtype setup onnx --enable`.
3. Config (`~/.config/voxtype/config.toml`, backup
   `config.toml.bak.1790112721`, copy in [`dictation/`](dictation/config.toml)):
   `engine = "parakeet"`, `[parakeet] model = "parakeet-unified-en-0.6b"`,
   `streaming = true`.
4. The daemon then crash-looped: `left_context_secs must map to a mel-frame
   count divisible by 8`. The defaults are invalid for this model. Set, as
   multiples of 0.08 s: `streaming_chunk_secs = 0.56`,
   `streaming_left_context_secs = 5.6`, `streaming_right_context_secs = 0.56`.
   These keys are not in `voxtype config schema`; they were found in the
   error text and the binary.
5. `systemctl --user restart voxtype`: "Parakeet streaming model loaded in
   1.59s (chunk=0.56s, left=5.60s, right=0.56s) … ready for voice input".
   The daemon uses about 2.5 GB of RAM (30 GB installed), on the CPU (no
   discrete GPU).

Notes:

- Streaming forces toggle mode. voxtype warns that holding a key while it
  types makes Hyprland lose the key's release, so hold-F9 push-to-talk is
  unreliable now. Use Win+H.
- Text is typed at the cursor while you speak, so it goes wherever keyboard
  focus is. An invisible Omarchy panel holding focus (see
  [TROUBLESHOOTING.md](TROUBLESHOOTING.md)) would swallow it.
- **Confirmed by Josh** (2026-09-22): the waveform shows, text appears
  quickly after speaking, and it is accurate. Keeping it.

## Recording length

Josh: dictation sometimes stopped on its own while he was still talking. That
was voxtype's safety cap `audio.max_duration_secs = 60`. Raised to **600**
(10 minutes; allowed 5–3600) with `voxtype config set` and restarted the
service; `voxtype config get` confirms 600. Copy in
[`dictation/config.toml`](dictation/config.toml).

## Undo (back to Whisper)

```bash
pkexec voxtype setup onnx --disable
cp ~/.config/voxtype/config.toml.bak.1790112721 ~/.config/voxtype/config.toml
systemctl --user restart voxtype
rm -rf ~/.local/share/voxtype/models/parakeet-unified-en-0.6b   # frees 2.4 GB
```
