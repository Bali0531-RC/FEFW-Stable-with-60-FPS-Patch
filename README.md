# FEFW-Stable-with-60-FPS-Patch
Portable, ready-to-play Windows build of the Eden FE: Fortune’s Weave emulator fork (based on xDarkWindx 1.12 and Duck912's forks). Runs on any x64 CPU, settings pre-tuned for Fortune’s Weave, plus a start-up crash fix. Bring your own keys, firmware and game.

Information:
Eden FE: Fortune’s Weave – Portable Build

A ready-to-play Windows build of the Eden emulator fork made for Fire Emblem: Fortune’s Weave, based on xDarkWindx’s eden-fefw 1.12. Unzip it, add your own keys and firmware, and play. Nothing to install, and it won’t touch any other Eden setup you have.

What’s different from upstream 1.12
Start-up crash fix: the emulator no longer closes on launch when Windows refuses to delete an empty save-profile folder. It also never deletes a save folder it can’t read, where the original code could.
Settings ready for Fortune’s Weave: the 12 GB memory layout the game needs, GPU mode Fast, asynchronous shaders and tuned graphics settings, already applied. Only controls need setting up.
Fully portable: settings, saves, keys, firmware and shader cache all stay inside the folder.
Runs on any PC: built without CPU-specific instructions, with the Microsoft C++ runtime included.
60 fps cheat included (optional): can be switched under the game’s Properties → Add-Ons. It only works with the matching game version.
Requirements
64-bit Windows 10 or 11
A Vulkan-capable GPU (an NVIDIA RTX card is recommended)
16 GB of RAM or more, with a large page file: the 12 GB layout reserves a lot of memory up front
Your own keys, firmware and game, dumped from your own console. None are included.
Getting started
Extract the whole folder somewhere outside Program Files and run eden.exe.
Say Yes when it asks for decryption keys, and pick your prod.keys.
Tools → Install Firmware, then pick your firmware.
Double-click the empty game list to add your game folder.
Credits and licence

Built on Eden, Duck912’s Fortune’s Weave fork and xDarkWindx’s 1.12 release. Licensed under GPL-3.0-or-later; the full source for this build is included as source.zip and in this repository.

**If having issues, try deleting the 60 fps patch**

Locked 30 fps throughout the game after multiple hours of testing on 4090 9800x3d.
