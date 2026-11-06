# Fortune's Eden (FEFW Stable with 60 FPS Patch)

**Current version: v1.3** — profile-guided optimisation trained on Fortune's Weave, loose files and `.nup` share one save folder, the app is now called *Fortune's Eden*, and shutdown fixes from other forks. See [CHANGELOG.md](CHANGELOG.md).

A portable, ready-to-play Windows build of the Eden emulator fork made for *Fire Emblem: Fortune's Weave*. It builds on [Duck912's Fortune's Weave fork](https://github.com/Duck912/eden-ns2-fe) and [xDarkWindx's eden-fefw 1.12](https://github.com/xDarkWindx/eden-fefw/releases/tag/1.12), which is based on it. Unzip it, point it at your game, and play. Nothing to install, and it won't touch any other Eden setup you have.

> [!NOTE]
> **30 FPS is how Fortune's Weave runs on Switch 2**, and it's how this build runs by default: smoothly, everywhere.
> **Fast PC?** A 60 FPS patch is included but **off by default**, because 60 FPS can feel choppy. On high-end CPUs it's fairly smooth at **1x resolution** (FSR upscales to your screen); higher resolutions roughly double the choppiness. To try it, right-click the game → *Properties → Add-Ons* and tick **60fps**. If it causes problems, untick it; if it still feels choppy, **delete** the folder `user\load\04007EF01F8AE000\60fps` (next to `Fortune's Eden.exe`), as unticking it isn't always enough.

> [!IMPORTANT]
> **Your saves are stored next to `Fortune's Eden.exe`, not in the normal Eden location.**
> This build is portable: saves live in `user\nand\user\save` **inside the folder you extracted**, *not* in `%APPDATA%\eden`. It won't see saves from another Eden install until you copy them in, and deleting or replacing this folder deletes its saves. See [Saves](#saves) below.

**Download:** see the [latest release](../../releases/latest), or [FEFW-Stable-60FPS-Portable.zip](../../raw/main/download/FEFW-Stable-60FPS-Portable.zip) (about 37 MB). Extract the whole folder, then follow *Getting started* below.

## What's different from upstream (xDarkWindx 1.12)

- **Faster on the CPU side:** built with profile-guided optimisation (PGO) trained on Fortune's Weave (Dagdion, battles, menus). The emulator's own code for feeding the GPU is laid out for the paths the game actually uses; it still runs on any x64 CPU. In testing at 60 FPS it cut doubled frames by about a quarter.
- **One save folder for loose files and `.nup`:** loose-file dumps now use the game's real ID, like `.nup`, cartridge and eShop dumps. Saves made with loose files in older versions are copied across automatically the first time (the old copy is kept).
- **Plays `.nup` files:** load the game as a single `.nup` package as well as loose files. The NUP loader is ported from [Djihads80's Eglantine](https://github.com/Djihads80/Eglantine). Playing only: packing, unpacking and editing NUPs aren't included, and add-on content inside a `.nup` isn't loaded.
- **AMD graphics fix:** shader registers that a game reads before writing are treated as zero, as NVIDIA hardware does, instead of leftover garbage, which on AMD GPUs can show as stray coloured patches. Ported from Eglantine (by arisqz).
- **Shutdown and restart fixes:** no hang when stopping the game if its audio renderer outlives its manager (kraibse), and starting the game again in the same window no longer hangs or crashes (Takoroka), both from PokeDinner, an Eglantine fork. Clearer logs for missing keys and unsupported system calls, and an error-reporting crash fix (xDarkWindx).
- **Start-up crash fix:** the emulator no longer closes on launch when Windows refuses to delete an empty save-profile folder, and never deletes a save folder it can't read.
- **Settings ready for Fortune's Weave, all global:** the 12 GB memory layout the game needs, GPU accuracy Fast, asynchronous shaders on, vsync off, 16x anisotropic filtering, VRAM Usage Mode Conservative, AMD FSR window filter at 50% sharpness and anti-aliasing off, set under *Emulation → Configure* so they apply however your game is dumped or packed. Only controls need setting up.
- **Fully portable:** settings, **saves** and shader cache all stay in the `user` folder next to `Fortune's Eden.exe` (see [Saves](#saves)).
- **Runs on any PC:** built without CPU-specific instructions, with the Microsoft C++ runtime included.

## Requirements

- 64-bit Windows 10 or 11
- A Vulkan-capable GPU (an NVIDIA RTX card is recommended)
- **16 GB of RAM or more, with a large page file** (system-managed, or about 32 GB): the 12 GB memory layout reserves a lot of memory up front, and too small a page file makes the emulator close as the game starts
- Your own copy of the game, dumped from your own console, as loose files (exefs/romfs) or a single `.nup` file. **No games, keys or firmware are included.**

## Getting started

1. Extract the whole folder somewhere outside Program Files and run `Fortune's Eden.exe`.
2. Double-click the empty game list and choose the folder containing your game (or use *File → Load File* to open a `.nup` directly).

## Saves

- **Where they are:** `<your folder>\user\nand\user\save\0000000000000000\<profile ID>\04007EF01F8AE000\`, inside the folder that holds `Fortune's Eden.exe`. Nothing is written to `%APPDATA%\eden`. Loose files and `.nup` both use this folder (since v1.3).
- **Bring saves from normal Eden or another emulator build:** close both, then copy the whole `%APPDATA%\eden\nand` folder (or the old build's `user\nand`) into this build's `user` folder, replacing the `nand` there. Copy the whole `nand`, not just the save files: it holds your user profile too.
- **Coming from an older version with loose files?** Older versions saved loose-file games under game ID `0000000000000000`. v1.3 copies that save to `04007EF01F8AE000` the first time you start the game, if there's no save there yet. If you also have an older `04007EF01F8AE000` folder (from playing a `.nup`), that one is used instead; keep whichever is newer as `04007EF01F8AE000`.
- **Updating to a new version:** extract it to a new folder and copy your old `user\nand` across (or the whole `user` folder to keep settings and shader cache). Don't extract over the old folder without copying `user` out first.
- **Back them up:** copy or zip the `user\nand` folder.

## Troubleshooting

- **Closes as soon as the game starts:** usually not enough memory for the 12 GB layout. Enlarge the Windows page file and close other heavy apps.
- **Stuck on loading:** the game needs the 12 GB memory layout. Check *Emulation → Configure → System → Memory Layout* says 12 GB. If you've ever changed the game's own settings (right-click the game → *Properties → System*), check there too, since a per-game setting overrides the global one. Copying a `user` folder from an older build can also bring back 4 GB.
- **Short hitches in new areas:** that's first-time shader translation. It's saved to the shader cache, so revisits are smooth. Copying your old `user\cache` folder into a new version keeps it.
- **Freezes of about a second (picture and sound) after playing for a while, even in areas you've visited before:** make sure **VRAM Usage Mode** is **Conservative** (the default since v1.1): *Emulation → Configure → Graphics → Advanced* (and the game's own *Properties*, if you've changed it there). On *Aggressive* the texture cache can fill most of your graphics card's memory during a long session and spill over into much slower system RAM.

## Building from source

The emulator source for this build is in `source.zip` (also inside the release download). It builds with Visual Studio 2026 (MSVC 19.51) and CMake:

1. Put `Build-Local-MSVC.ps1`, `Save-PGO.ps1`, `cmake-options.txt`, `LICENSE`, the `portable-config` folder and `source.zip` together in a folder whose path has no spaces, and rename `source.zip` to `eden-fefw-1.12-local.zip`.
2. In PowerShell in that folder: `Set-ExecutionPolicy -Scope Process Bypass; .\Build-Local-MSVC.ps1 -Version 1.12 -Portable`

That gives `FEFW-Stable-60FPS-Portable` (with `Fortune's Eden.exe`) and a zip of it, with the settings from `portable-config/`. For the PGO build used in releases:

1. `.\Build-Local-MSVC.ps1 -Version 1.12 -Portable -Pgo Train` builds a measuring copy in `FEFW-PGO-Training`.
2. Play Fortune's Weave in it for 10–20 minutes, and **while it's still running** run `.\Save-PGO.ps1` to save the measurements.
3. `.\Build-Local-MSVC.ps1 -Version 1.12 -Portable -Pgo Use` builds the optimised package.

## Credits and licence

Built on [Eden](https://eden-emu.dev), [Duck912's Fortune's Weave fork](https://github.com/Duck912/eden-ns2-fe) and [xDarkWindx's 1.12 release](https://github.com/xDarkWindx/eden-fefw), with the NUP loader and AMD fix from [Djihads80's Eglantine](https://github.com/Djihads80/Eglantine) and shutdown fixes from PokeDinner (kraibse, Takoroka). Licensed under **GPL-3.0-or-later**; the full source for this build is included as `source.zip`. Not affiliated with Nintendo. Please only use games dumped from hardware you own.
