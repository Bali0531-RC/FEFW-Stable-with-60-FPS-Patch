# Changelog

## v1.4.1

- **Cutscenes no longer drop to about 5 FPS.** Fortune's Weave's 1440p cutscenes are AV1 videos, and in their busiest scenes decoding a frame took up to ~40 ms, more than the 33 ms a 30 FPS video allows. Whenever the video fell behind, the game's frame rate collapsed until the scene got lighter. Their frames are encoded as a single tile, so the decoder (libgav1) worked mostly on one thread however many it had. It now decodes several frames at once (frame-parallel, 12 threads on a 16-thread CPU): in the same cutscene the decoder now keeps up with time to spare, and the cutscene plays at a steady 30 FPS. `EDEN_AV1_THREADS=N` sets the thread count; `EDEN_AV1_FRAME_PARALLEL=0` decodes one frame at a time as before.
- **Stricter check on the v1.3.1 handle-table shortcut** (a precaution for the sky sometimes turning dark in Dagsion). The shortcut reuses texture-handle tables the game builds on the GPU instead of waiting for them, and checks the GPU's copy afterwards. A table now needs 32 identical reads before the shortcut is used for it (was 8), a table that ever changes is always waited for from then on, and every table is still read for real at least every 250 ms. Changes are logged (`Texture-handle table ... changed`). In testing no table changed, so 60 FPS keeps the v1.3.1 gain. `EDEN_SPECULATIVE_HANDLES=0` still turns the shortcut off.

- **A copied `user` folder now uses its own saves.** Settings stored the full path of the build's NAND, SD, mod and dump folders, so a `user` folder copied into a new build (as the update steps say) kept using the folders of the build it came from: saves kept going to the old folder, and *Open Save Data Location* opened that one. Paths pointing at another build's `user\nand` (and `sdmc`, `load`, `dump`, `tas`) are now ignored in favour of this build's own, and this build's own folders are stored without a full path, so the `user` folder works wherever it is copied. A folder you picked yourself elsewhere is kept. If you updated by copying a `user` folder before, your latest saves may still be in the old build's `user\nand`: copy that `nand` folder over this build's `user\nand`.

**Updating from v1.4:** extract v1.4.1 to a new folder and copy your old `user` folder into it.

## v1.4

> **30 FPS is how Fortune's Weave runs on Switch 2**, and this build runs it smoothly by default. The 60 FPS patch stays **off by default**.

- **Optional NVIDIA DLSS in place of the game's own DLSS** (GeForce RTX cards). The game upscales with a small DLSS network made for the Switch 2, which can leave ghosting around moving characters. With *Graphics → Use NVIDIA DLSS in place of the game's DLSS* ticked, the full PC version of NVIDIA DLSS (through NVIDIA Streamline) does that step instead, from the game's own colour, depth, motion vectors and camera jitter. Off by default. NVIDIA's files aren't included: the **Download from NVIDIA** button under the setting fetches them from NVIDIA's Streamline release (or uses the DLSS the NVIDIA app has downloaded). If DLSS can't run, the game's own DLSS runs as before. Ported from Duck912's work in Eglantine; this build looks up DLSS's input images without creating any, which stopped driver crashes in an early port.
- **New default image settings:** AMD FSR window filter at **0% sharpness** (was 50%) and **FXAA** anti-aliasing (was off). FXAA softens the ghosting of the game's own DLSS, and 50% sharpness looked oversharpened with NVIDIA DLSS.

**Updating from v1.3.1:** extract v1.4 to a new folder and copy your old `user` folder into it. A copied `user` folder keeps your old image settings: set *Window Adapting Filter* sharpness to 0% and *Anti-Aliasing* to FXAA yourself if you want the new defaults.

## v1.3.1

> **30 FPS is how Fortune's Weave runs on Switch 2**, and this build still runs it smoothly by default. The 60 FPS patch stays **off by default**, but it's noticeably smoother in busy scenes now; on a fast PC, try it at **1x resolution**.

- **Smoother 60 FPS in busy scenes.** The game builds some texture-handle tables with compute shaders and draws with them a few draws later. Reading them back made the emulator wait for the GPU about once a frame (up to ~1.3 ms), although the tables never change. Once a table has come back identical 8 times in a row, the emulator uses the copy it already has, checks the GPU's version once it's ready, and goes back to waiting for that table if they ever differ (in testing they never did). `EDEN_SPECULATIVE_HANDLES=0` turns this off.
- **Less lock contention from CPU writes.** Each CPU core now remembers the last 16 GPU-owned pages it wrote to (was 1), so repeated writes skip the cache lock: up to ~200,000 fewer lock calls a second in busy scenes. `EDEN_CPU_WRITE_PAGES=1` restores the old behaviour.
- **Fewer shader-compile stutters:** translated shaders are reused between graphics pipelines that share them (Wael3rd, from PokeDinner, an Eglantine fork). `EDEN_NX2_SHADER_REUSE=0` turns it off.
- **Measured** on a Ryzen 7 9800X3D + RTX 4090 at 60 FPS, 1x, running the same loop in Dagsion: doubled frames in the busiest section went from about 45% to about 20%; over the whole run, frames on time went from 78% to 89%.
- **Profile-guided optimisation retrained** with these changes.
- **Build script:** `-Symbols` builds a copy with debugging symbols for profiling (same code).

**Updating from v1.3:** extract v1.3.1 to a new folder and copy your old `user` folder into it (saves, settings and shader cache), or just `user\nand` for saves only.

## v1.3

> **30 FPS is how Fortune's Weave runs on Switch 2**, and this build runs it smoothly by default. The 60 FPS patch stays **off by default**; on a fast PC, try it at **1x resolution**.

> **Saves are stored next to `Fortune's Eden.exe`** (in `user\nand`), **not** in `%APPDATA%\eden`. See [Saves](README.md#saves).

- **Renamed to Fortune's Eden:** the app is now `Fortune's Eden.exe`, and its window is titled *Fortune's Eden*.
- **Profile-guided optimisation** trained on Fortune's Weave (Dagsion, battles, menus). The emulator's CPU-side code is laid out for the paths the game uses; still runs on any x64 CPU. At 60 FPS it cut doubled frames by about a quarter in testing; at 30 FPS the game was already on time almost every frame.
- **Loose files and `.nup` share one save folder.** Loose-file dumps now register the game's real ID (`04007EF01F8AE000`) instead of `0000000000000000`. The first time you start the game, an old loose-file save is copied across automatically if there's no save under the new ID yet (the old folder is kept).
- **Shutdown and restart fixes** from PokeDinner (an Eglantine fork): no hang on stop when the audio renderer outlives its manager (kraibse); starting the game again in the same window no longer hangs or crashes (Takoroka).
- **Error-reporting crash fix** and clearer logs for unsupported system calls and missing keys (xDarkWindx).
- **60 FPS advice:** measured on a Ryzen 7 9800X3D + RTX 4090, 1x resolution halved the 60 FPS choppiness compared with 2x (doubled frames 3.4% vs 6.5%).
- **Build script:** portable PGO (`-Pgo Train` / `-Pgo Use`) and `Save-PGO.ps1`.

**Updating from v1.2.x:** extract v1.3 to a new folder and copy your old `user\nand` folder into it (and `user\cache` to keep the shader cache). Loose-file saves are carried over automatically.

## v1.2.1

- **All settings are now global** (*Emulation → Configure*) instead of in a Fortune's Weave per-game profile, including the 12 GB memory layout. A per-game profile only applies when the game's ID matches exactly, so some dumps (for example a `.nup` packed with a different ID) or an old `user` folder copied over could fall back to the defaults, including 4 GB, which hangs on loading. The global settings now match what the profile had: GPU accuracy Fast, asynchronous shaders on, vsync off, 16x anisotropic filtering, reactive flushing off, VRAM Conservative, FSR at 50% sharpness, anti-aliasing off. The emulator itself is unchanged from v1.2.

**Updating from v1.2:** no need to re-download if your game loads. Otherwise set *Emulation → Configure → System → Memory Layout* to **12 GB**, or extract v1.2.1 and copy your `user\nand` folder into it.

## v1.2

> **The 60 FPS patch is now OFF by default.** Its frame pacing is poor and can feel choppy, while 30 FPS runs flawlessly. It's still included: to try it, right-click the game → *Properties → Add-Ons* and tick **60fps**.

> **Saves are stored next to `eden.exe`** (in `user\nand`), **not** in `%APPDATA%\eden`. See [Saves](README.md#saves).

- **60 FPS patch off by default** (unticked under *Add-Ons*; the files are still included).
- **AMD graphics fix:** shader registers read before being written are now zero, as on NVIDIA, instead of leftover garbage that can show as stray coloured patches on AMD GPUs. Ported from [Djihads80's Eglantine](https://github.com/Djihads80/Eglantine) (by arisqz). No change on NVIDIA.
- **Preset graphics:** AMD FSR window adapting filter at 50% sharpness, anti-aliasing off (was FXAA).
- **Building from source fixed:** `cmake-options.txt` is now in the repo, and the README lists exactly what to put together.
- `source.zip` updated with the AMD fix.

**Updating from v1.1:** extract v1.2 to a new folder and copy your old `user\nand` folder into it to keep your saves. If you copy the whole old `user` folder instead, your old graphics and 60 FPS settings come with it.

## v1.1

> **The 60 FPS patch has poor frame pacing: it can feel choppy and uneven. At the game's normal 30 FPS this build runs flawlessly.**
> The patch is on by default. For the smoothest experience, turn it off. If it still feels choppy **delete** the folder `user\load\04007EF01F8AE000\60fps` (next to `eden.exe`). Unticking it under *Add-Ons* isn't always enough.

> **Saves are stored next to `eden.exe`** (in `user\nand`), **not** in `%APPDATA%\eden`. Copy your `nand` folder in to keep existing saves. See [Saves](README.md#saves).

- **`.nup` support.** Fortune's Weave can now be played from a single `.nup` package as well as from loose files. Add the folder that holds it to the game list, or open it with *File → Load File*. The NUP loader is ported from [Djihads80's Eglantine](https://github.com/Djihads80/Eglantine) (GPL-3.0-or-later). Only playing is supported: packing, unpacking and editing NUPs aren't included, and add-on content inside a `.nup` isn't loaded.
- **VRAM Usage Mode is now Conservative** in the Fortune's Weave profile (it was Aggressive). On Aggressive the texture cache can grow to almost the whole graphics card during a long session and spill into system RAM, causing repeated one-second freezes of picture and sound after about half an hour. Conservative caps it at about 6 GB plus 1 GB per resolution-scale step.
- The download zip now uses standard forward-slash paths, so it extracts correctly with 7-Zip and other tools as well as Windows.
- `source.zip` is updated with the NUP code.
- **Switching from loose files to `.nup`?** The two save to different folders (`0000000000000000` vs `04007EF01F8AE000` inside your profile folder). Copy the first to the second to carry your progress over. See [Saves](README.md#saves).

**Updating from v1.0:** extract v1.1 to a new folder, then copy your old `user\nand` folder into it to keep your saves (or copy the whole old `user` folder to keep your settings and shader cache too). If you copy the whole `user` folder, set VRAM Usage Mode to Conservative yourself: right-click the game → *Properties → Graphics → Advanced*.

## v1.0

- First release: portable build of xDarkWindx's eden-fefw 1.12 (on Duck912's Fortune's Weave fork) with a start-up crash fix, settings tuned for Fortune's Weave, the 60 FPS patch and the Microsoft C++ runtime included.
