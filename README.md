# FEFW Stable with 60 FPS Patch

A portable, ready-to-play Windows build of the Eden emulator fork made for *Fire Emblem: Fortune's Weave*, based on [xDarkWindx's eden-fefw 1.12](https://github.com/xDarkWindx/eden-fefw/releases/tag/1.12). Unzip it, point it at your game, and play. Nothing to install, and it won't touch any other Eden setup you have.

**Download:** see [Releases](../../releases) for `FEFW-Stable-60FPS-Portable.zip`.

## What's different from upstream (xDarkWindx 1.12)

- **Start-up crash fix:** the emulator no longer closes on launch when Windows refuses to delete an empty save-profile folder. It also never deletes a save folder it can't read, where the original code could.
- **Settings ready for Fortune's Weave:** the 12 GB memory layout the game needs, GPU mode Fast, asynchronous shaders and tuned graphics settings, already applied. Only controls need setting up.
- **60 FPS patch included:** installed and on by default. If you have problems with it (uneven frame pacing, glitches), **delete** the folder `user\load\04007EF01F8AE000\60fps` to go back to the game's normal 30 fps. Unticking it under *Add-Ons* isn't always enough. It only works with the game version whose build ID starts `DB93B0125F485060`.
- **Fully portable:** settings, saves, keys, firmware and shader cache all stay inside the folder.
- **Runs on any PC:** built without CPU-specific instructions, with the Microsoft C++ runtime included.

## Requirements

- 64-bit Windows 10 or 11
- A Vulkan-capable GPU (an NVIDIA RTX card is recommended)
- **16 GB of RAM or more, with a large page file** (system-managed, or about 32 GB): the 12 GB memory layout reserves a lot of memory up front, and too small a page file makes the emulator close as the game starts
- Your own game, dumped from your own console. **No games, keys or firmware are included.**
- **Loose-file dumps (exefs/romfs) don't need keys or firmware.** Encrypted NSP/XCI dumps do: install your own `prod.keys` and firmware for those.

## Getting started

1. Extract the whole folder somewhere outside Program Files and run `eden.exe`.
2. Double-click the empty game list and choose the folder containing your game.
3. *Only for encrypted NSP/XCI dumps:* add your own keys (*Tools → Install Decryption Keys*) and firmware (*Tools → Install Firmware*). Loose-file dumps skip this; just dismiss any keys prompt.

## Troubleshooting

- **Closes as soon as the game starts:** usually not enough memory for the 12 GB layout. Enlarge the Windows page file and close other heavy apps.
- **Stuck on loading:** check the game's memory layout is 12 GB (right-click the game → *Properties*). For NSP/XCI dumps, also check keys and firmware are installed.
- **Short hitches in new areas:** that's first-time shader translation. It's saved to the shader cache, so revisits are smooth.

## Building from source

The emulator source for this build is in `source.zip` (also inside the release download). It builds with Visual Studio 2026 (MSVC) and CMake using `Build-Local-MSVC.ps1`: put the script next to the unpacked source as described in its header, then run `.\Build-Local-MSVC.ps1 -Version 1.12 -Portable`. The pre-set settings it packages live in `portable-config/`.

## Credits and licence

Built on [Eden](https://eden-emu.dev), Duck912's Fortune's Weave fork and [xDarkWindx's 1.12 release](https://github.com/xDarkWindx/eden-fefw). Licensed under **GPL-3.0-or-later**; the full source for this build is included as `source.zip`. Not affiliated with Nintendo. Please only use games, keys and firmware from hardware you own.
