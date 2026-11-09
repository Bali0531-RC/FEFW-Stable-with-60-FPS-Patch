# Fortune's Eden (FEFW Stable with 60 FPS Patch)

**Current version: v1.6.5** — new **Upscaler quality** setting: the 3D scene can be drawn bigger than the game's own 720p (Native, Ultra Quality, Quality, **Balanced** by default, or Performance) while the menus and text stay at 1440p, with FSR 3.1, NVIDIA DLSS (DLAA at Native) or FSR 4 at 1X. v1.6.4: busy scenes run faster (each draw is prepared about 40% faster: the Saramis hub went from 53–55 FPS to a steady 60), **automatic updates** (it asks first, verifies the download and never touches saves or settings), and AMD FSR 4 now starts on Radeon RX 6000/7000/9000. v1.6.3 was a PGO build again (v1.6.2's download was built without it and ran slower on the CPU side), earlier video memory cleanup on big cards, and AMD FSR 3.1 as the default upscaler (one dropdown for all of them). v1.6.2 added **HDR output**, optional **AMD FSR 3.1** (any card) and **AMD FSR 4** (RX 7000/9000), and a big fixes release from a full code review: crash and save fixes, sound clicks and 4-core stutter, fewer cleanup hitches on 8 GB cards, and new default image settings (Bilinear, no FXAA, vsync Mailbox). v1.6.1 fixed 8 GB cards dropping to 2 FPS when a scene loads many textures and labelled the resolution options with this game's real sizes (2X is 5K). v1.6: battle starts no longer freeze while textures convert: the GPU now re-compresses the game's textures itself, so every card gets the small, smooth BC3 textures (ASTC recompression Auto picks them), plus smoother play when video memory fills up. v1.5.2 fixed a crash in the NVIDIA driver with DLSS on. v1.5.1 brought smoother sound on laptops and 4-core CPUs, no more battle-start freezes from texture conversion on big cards (ASTC recompression now picks itself), big cards may use more of their video memory, the menu shows the game update's version, and crash fixes. v1.5 fixed the sky turning black after opening the map, a recurring stutter, and missing cutscene voices, and added an optional ultrawide setting (off by default). v1.4.2 fixed 3D scenes losing their background (bath scenes going black around the characters); v1.4.1 stopped cutscenes dropping to about 5 FPS and made a copied `user` folder use its own saves; v1.4 added optional **NVIDIA DLSS** and new default image settings (FSR at 0% sharpness with FXAA). See [CHANGELOG.md](CHANGELOG.md).

A portable, ready-to-play Windows build of the Eden emulator fork made for *Fire Emblem: Fortune's Weave*. It builds on [Duck912's Fortune's Weave fork](https://github.com/Duck912/eden-ns2-fe) and [xDarkWindx's eden-fefw 1.12](https://github.com/xDarkWindx/eden-fefw/releases/tag/1.12), which is based on it. Unzip it, point it at your game, and play. Nothing to install, and it won't touch any other Eden setup you have.

> [!NOTE]
> **30 FPS is how Fortune's Weave runs on Switch 2**, and it's how this build runs by default: smoothly, everywhere.
> **Fast PC?** A 60 FPS patch is included but **off by default**, because 60 FPS can feel choppy. On high-end CPUs it's fairly smooth at **1x resolution** (FSR upscales to your screen); higher resolutions roughly double the choppiness. To try it, right-click the game → *Properties → Add-Ons* and tick **60fps**. If it causes problems, untick it; if it still feels choppy, **delete** the folder `user\load\04007EF01F8AE000\60fps` (next to `Fortune's Eden.exe`), as unticking it isn't always enough.

> [!CAUTION]
> **Legal use only. Piracy is not acceptable and is not supported in any way.** Please support the developers by buying the games you play.
> - **Nothing of Nintendo's is included or linked:** no games, ROMs, keys (`prod.keys`, `title.keys`), firmware, system files or copyrighted game assets. This repository, its releases and its downloads contain only the emulator, its source code, settings, and a small community cheat code for 60 FPS.
> - **You need your own legally obtained copy of the game, dumped yourself from your own console**, along with your own keys and firmware dumped from that same console. How to get these is not covered here, and no help is given for obtaining them any other way.
> - **Issues, discussions or requests involving pirated games, shared keys or downloaded firmware will be closed** without help.
> - This is a free, non-commercial project: no donations, paywalls or paid early access.
> - Not affiliated with, endorsed by or sponsored by Nintendo, NVIDIA or AMD. *Fire Emblem: Fortune's Weave* and Nintendo Switch are trademarks of Nintendo; NVIDIA and DLSS are trademarks of NVIDIA; AMD, FSR and FidelityFX are trademarks of AMD. Names are used only to describe compatibility.
> - Development and testing were done only with legally dumped copies of the game, keys and firmware from the maintainer's own hardware.

> [!IMPORTANT]
> **Your saves are stored next to `Fortune's Eden.exe`, not in the normal Eden location.**
> This build is portable: saves live in `user\nand\user\save` **inside the folder you extracted**, *not* in `%APPDATA%\eden`. It won't see saves from another Eden install until you copy them in, and deleting or replacing this folder deletes its saves. See [Saves](#saves) below.

**Download:** see the [latest release](../../releases/latest), or [FEFW-Stable-60FPS-Portable.zip](../../raw/main/download/FEFW-Stable-60FPS-Portable.zip) (about 37 MB). Extract the whole folder, then follow *Getting started* below.

## What's different from upstream (xDarkWindx 1.12)

- **HDR output (HDR10):** the game's own Switch 2 HDR mode, with its Brightness and UI Brightness options. Off by default; see [HDR](#hdr-optional).
- **AMD FSR 3.1 by default, AMD FSR 4 optional** in place of the game's own DLSS: FSR 3.1 on any card, FSR 4 on AMD Radeon RX 6000/7000/9000 (AMD's own FSR 4.1.2 library from the [FSR SDK 2.4](https://gpuopen.com/manuals/fidelityfx_sdk2/whats-new/)). Off by default; see [Upscalers](#upscalers-optional).
- **Optional NVIDIA DLSS:** on GeForce RTX cards, the game's own lightweight DLSS (the Switch 2's upscaler, which can leave ghosting around moving characters) can be replaced with the full PC version of NVIDIA DLSS. Off by default; see [NVIDIA DLSS](#nvidia-dlss-optional). Ported from Duck912's work in [Eglantine](https://github.com/Djihads80/Eglantine).
- **Smoother 60 FPS in busy scenes:** the game builds some texture-handle tables on the GPU and reads them a few draws later. The emulator used to stop and wait for the GPU about once a frame to read them back, although they never change. It now uses the copy it has and checks it against the GPU's version afterwards, going back to waiting if they ever differ. CPU writes to GPU memory also take the cache lock far less often. In Dagsion's busiest section at 60 FPS (1x), doubled frames went from about 45% to about 20%.
- **Fewer shader-compile stutters:** translated shaders are reused between graphics pipelines that share them, so new areas hitch less the first time (Wael3rd, from PokeDinner, an Eglantine fork).
- **Faster on the CPU side:** built with profile-guided optimisation (PGO) trained on Fortune's Weave (Dagsion, battles, menus). The emulator's own code for feeding the GPU is laid out for the paths the game actually uses; it still runs on any x64 CPU. In testing at 60 FPS it cut doubled frames by about a quarter.
- **One save folder for loose files and `.nup`:** loose-file dumps now use the game's real ID, like `.nup`, cartridge and eShop dumps. Saves made with loose files in older versions are copied across automatically the first time (the old copy is kept).
- **Plays `.nup` files:** load the game as a single `.nup` package as well as loose files. The NUP loader is ported from [Djihads80's Eglantine](https://github.com/Djihads80/Eglantine). Playing only: packing, unpacking and editing NUPs aren't included, and add-on content inside a `.nup` isn't loaded.
- **AMD graphics fix:** shader registers that a game reads before writing are treated as zero, as NVIDIA hardware does, instead of leftover garbage, which on AMD GPUs can show as stray coloured patches. Ported from Eglantine (by arisqz).
- **Shutdown and restart fixes:** no hang when stopping the game if its audio renderer outlives its manager (kraibse), and starting the game again in the same window no longer hangs or crashes (Takoroka), both from PokeDinner, an Eglantine fork. Clearer logs for missing keys and unsupported system calls, and an error-reporting crash fix (xDarkWindx).
- **Start-up crash fix:** the emulator no longer closes on launch when Windows refuses to delete an empty save-profile folder, and never deletes a save folder it can't read.
- **Settings ready for Fortune's Weave, all global:** the 12 GB memory layout the game needs, GPU accuracy Fast, asynchronous shaders on, vsync Mailbox, 16x anisotropic filtering, VRAM Usage Mode Conservative, Bilinear window filter and anti-aliasing off, set under *Emulation → Configure* so they apply however your game is dumped or packed. Only controls need setting up.
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

## NVIDIA DLSS (optional)

For GeForce RTX cards. The game renders at a lower resolution and upscales with its own small DLSS network, built for the Switch 2. This build can hand that step to the full PC version of NVIDIA DLSS instead, using the game's own colour, depth and motion data: a sharper picture with less ghosting.

1. *Emulation → Configure → Graphics*, set **Upscaler** to **NVIDIA DLSS (GeForce RTX)**.
2. In the panel below it, click **Download from NVIDIA** and accept NVIDIA's licences. NVIDIA's files aren't included in this download; they're fetched from NVIDIA's own Streamline release into `user\streamline` (if the NVIDIA app has already downloaded DLSS, only a 1 MB file is needed).
3. Start the game. If DLSS can't run, the game's own DLSS is used as before.

Recommended with it: *Window Adapting Filter* **Bilinear** and anti-aliasing **off**, the defaults. Pick the resolution so the output matches your screen (1.5X for 4K).

## Upscalers (optional)

The game upscales its 3D scene 2× with its own small DLSS network. Choose what does that in *Emulation → Configure → Graphics → Upscaler*:

- **AMD FSR 3.1** (any card, the default): replaces the game's network, which takes work off the emulator. Its sharpening follows the *FSR Sharpness* slider (25% by default). Edges are a little rougher in motion than with the game's own DLSS.
- **Game's own DLSS**: the game's own network, run as compute passes. Some prefer its look; it costs the emulator more.
- **NVIDIA DLSS** (GeForce RTX): the best picture by far. See above.
- **AMD FSR 4** (Radeon RX 6000/7000/9000): AMD's own FSR 4.1.2 Vulkan library from the [FSR SDK 2.4](https://gpuopen.com/manuals/fidelityfx_sdk2/whats-new/) (`amd_fidelityfx_upscaler_vk.dll` next to the exe, signed by AMD). RX 9000 cards run the full FP8 model, RX 7000 and RX 6000 cards an INT8 model. It needs an AMD card.

NVIDIA DLSS and FSR 4 fall back to FSR 3.1 when they can't start.

Each takes effect when the game starts; the log says which one ran ("Game DLSS replaced by ...").

## HDR (optional)

Fortune's Weave has an HDR mode on Switch 2. To use it: turn on HDR in Windows (*Settings → System → Display → Use HDR*), tick **HDR output (HDR10)** in *Emulation → Configure → Graphics*, and start the game. Its *Brightness* and *UI Brightness* options then adjust the picture. The game checks for HDR once when it starts, so restart it after changing either setting.

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

Built on [Eden](https://eden-emu.dev), [Duck912's Fortune's Weave fork](https://github.com/Duck912/eden-ns2-fe) and [xDarkWindx's 1.12 release](https://github.com/xDarkWindx/eden-fefw), with the NUP loader, AMD fix and NVIDIA DLSS support from [Djihads80's Eglantine](https://github.com/Djihads80/Eglantine) (Duck912, arisqz), and shader reuse and shutdown fixes from PokeDinner (Wael3rd, kraibse, Takoroka). AMD FSR 3.1 is built from AMD's FidelityFX SDK (MIT) with the upscaler from Eglantine (Duck912); AMD FSR 4 is AMD's own signed FSR 4.1.2 Vulkan library from the FSR SDK 2.4, redistributed unmodified under the FidelityFX SDK licence (`licenses\amd-fsr4`). AMD and FidelityFX are trademarks of AMD; this project is not made or endorsed by AMD. NVIDIA DLSS and Streamline are NVIDIA's; none of NVIDIA's files are included. Licensed under **GPL-3.0-or-later**; the full source for this build is included as `source.zip`. Not affiliated with, endorsed by or sponsored by Nintendo or NVIDIA. For use only with games, keys and firmware legally dumped from your own console; see the legal notice at the top.
