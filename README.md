# FEFW Stable with 60 FPS Patch

**Current version: v1.2** — 60 FPS patch now off by default, an AMD graphics fix, and FSR 50% / no anti-aliasing preset. See [CHANGELOG.md](CHANGELOG.md).

A portable, ready-to-play Windows build of the Eden emulator fork made for *Fire Emblem: Fortune's Weave*. It builds on [Duck912's Fortune's Weave fork](https://github.com/Duck912/eden-ns2-fe) and [xDarkWindx's eden-fefw 1.12](https://github.com/xDarkWindx/eden-fefw/releases/tag/1.12), which is based on it. Unzip it, point it at your game, and play. Nothing to install, and it won't touch any other Eden setup you have.

> [!WARNING]
> **The 60 FPS patch is now OFF by default (since v1.2).** Its frame pacing is poor and can feel choppy and uneven, while at the game's normal 30 FPS this build runs flawlessly.
> The patch is still included. To try it, right-click the game → *Properties → Add-Ons* and tick **60fps**. If it causes problems, untick it again; if it still feels choppy, **delete** the folder `user\load\04007EF01F8AE000\60fps` (next to `eden.exe`), as unticking it isn't always enough.

> [!IMPORTANT]
> **Your saves are stored next to `eden.exe`, not in the normal Eden location.**
> This build is portable: saves live in `user\nand\user\save` **inside the folder you extracted** (the one with `eden.exe`), *not* in `%APPDATA%\eden`. It won't see saves from another Eden install until you copy them in, and deleting or replacing this folder deletes its saves. See [Saves](#saves) below.

**Download:** [FEFW-Stable-60FPS-Portable.zip](../../raw/main/download/FEFW-Stable-60FPS-Portable.zip) (about 37 MB). Extract the whole folder, then follow *Getting started* below.

## What's different from upstream (xDarkWindx 1.12)

- **Plays `.nup` files:** load the game as a single `.nup` package as well as loose files. The NUP loader is ported from [Djihads80's Eglantine](https://github.com/Djihads80/Eglantine). Playing only: packing, unpacking and editing NUPs aren't included, and add-on content inside a `.nup` isn't loaded.
- **AMD graphics fix:** shader registers that a game reads before writing are treated as zero, as NVIDIA hardware does, instead of leftover garbage, which on AMD GPUs can show as stray coloured patches. Ported from [Djihads80's Eglantine](https://github.com/Djihads80/Eglantine) (by arisqz).
- **Start-up crash fix:** the emulator no longer closes on launch when Windows refuses to delete an empty save-profile folder. It also never deletes a save folder it can't read, where the original code could.
- **Settings ready for Fortune's Weave:** the 12 GB memory layout the game needs, GPU mode Fast, asynchronous shaders, VRAM Usage Mode Conservative, AMD FSR window filter at 50% sharpness, anti-aliasing off and other tuned graphics settings, already applied. Only controls need setting up.
- **60 FPS patch included, off by default:** its frame pacing is poor and can feel choppy, while 30 FPS is smooth. To try it, tick **60fps** under the game's *Properties → Add-Ons*. If it still feels choppy after unticking it, **delete** the folder `user\load\04007EF01F8AE000\60fps`. It only works with the game version whose build ID starts `DB93B0125F485060`.
- **Fully portable:** settings, **saves** and shader cache all stay inside the folder next to `eden.exe` (see [Saves](#saves)).
- **Runs on any PC:** built without CPU-specific instructions, with the Microsoft C++ runtime included.

## Requirements

- 64-bit Windows 10 or 11
- A Vulkan-capable GPU (an NVIDIA RTX card is recommended)
- **16 GB of RAM or more, with a large page file** (system-managed, or about 32 GB): the 12 GB memory layout reserves a lot of memory up front, and too small a page file makes the emulator close as the game starts
- Your own copy of the game, dumped from your own console, as loose files (exefs/romfs) or a single `.nup` file. **No games, keys or firmware are included.**

## Getting started

1. Extract the whole folder somewhere outside Program Files and run `eden.exe`.
2. Double-click the empty game list and choose the folder containing your game (or use *File → Load File* to open a `.nup` directly).

## Saves

- **Where they are:** `<your folder>\user\nand\user\save\0000000000000000\<profile ID>\<game ID>\`, inside the folder that holds `eden.exe`. Nothing is written to `%APPDATA%\eden`.
- **Bring saves from normal Eden or another emulator build:** close both, then copy the whole `%APPDATA%\eden\nand` folder (or the old build's `user\nand`) into this build's `user` folder, replacing the `nand` there. Copy the whole `nand`, not just the save files: it holds your user profile too.
- **Updating to a new version:** extract it to a new folder and copy your old `user\nand` across (or the whole `user` folder to keep settings and shader cache). Don't extract over the old folder without copying `user` out first.
- **Back them up:** copy or zip the `user\nand` folder.
- **Loose files and `.nup` use different save folders.** Loose files save under game ID `0000000000000000`, a `.nup` under `04007EF01F8AE000`. If you switch from loose files to a `.nup` and your saves are missing, close the emulator and copy the `0000000000000000` folder to `04007EF01F8AE000` (same profile folder). If a `04007EF01F8AE000` folder already exists, rename it first. After switching, stick to one format.

## Troubleshooting

- **Closes as soon as the game starts:** usually not enough memory for the 12 GB layout. Enlarge the Windows page file and close other heavy apps.
- **Stuck on loading:** check the game's memory layout is 12 GB (right-click the game → *Properties*).
- **Short hitches in new areas:** that's first-time shader translation. It's saved to the shader cache, so revisits are smooth.
- **Freezes of about a second (picture and sound) after playing for a while, even in areas you've visited before:** make sure **VRAM Usage Mode** is **Conservative** (the default since v1.1). Right-click the game → *Properties → Graphics → Advanced*. On *Aggressive* the texture cache can fill most of your graphics card's memory during a long session and spill over into much slower system RAM.

## Building from source

The emulator source for this build is in `source.zip` (also inside the release download). It builds with Visual Studio 2026 (MSVC 19.51) and CMake:

1. Put `Build-Local-MSVC.ps1`, `cmake-options.txt`, `LICENSE`, the `portable-config` folder and `source.zip` together in one folder, and rename `source.zip` to `eden-fefw-1.12-local.zip`.
2. In PowerShell in that folder: `Set-ExecutionPolicy -Scope Process Bypass; .\Build-Local-MSVC.ps1 -Version 1.12 -Portable`

The output is `FEFW-Stable-60FPS-Portable` and a zip of it, with the settings from `portable-config/`.

## Credits and licence

Built on [Eden](https://eden-emu.dev), [Duck912's Fortune's Weave fork](https://github.com/Duck912/eden-ns2-fe) and [xDarkWindx's 1.12 release](https://github.com/xDarkWindx/eden-fefw), with the NUP loader and AMD fix from [Djihads80's Eglantine](https://github.com/Djihads80/Eglantine). Licensed under **GPL-3.0-or-later**; the full source for this build is included as `source.zip`. Not affiliated with Nintendo. Please only use games dumped from hardware you own.
