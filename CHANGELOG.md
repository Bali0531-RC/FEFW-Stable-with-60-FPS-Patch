# Changelog

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
