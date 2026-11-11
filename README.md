# Fortune's Eden test builds

Unreleased builds for testers. Not for general use: get releases from the [Releases page](https://github.com/TheSneakyBadger/FEFW-Stable-with-60-FPS-Patch/releases).

No games, keys, firmware or saves are included.

| File | For | SHA-256 |
|---|---|---|
| `FEFW-Test-v1.6.7.5-test45.zip` | test44 plus: *Settings → Audio → Audio buffer* (Low, Medium, High) for crackling sound (#29); `EDEN_AUDIO_VOICE_STATS=1` logs what the audio renderer's voices did every 2 s (#22). Source: [`source-v1.6.7.5-test45`](https://github.com/TheSneakyBadger/FEFW-Stable-with-60-FPS-Patch/tree/source-v1.6.7.5-test45) | see `SHA256.txt` |
| `FEFW-Test-v1.6.7.5-test44.zip` | test43 plus: the audio renderer no longer drops voices over the console DSP's time estimate, and logs when it would (#22: missing dialogue in heavy cutscenes; `EDEN_AUDIO_VOICE_DROP=1` turns dropping back on). Source: [`source-v1.6.7.5-test44`](https://github.com/TheSneakyBadger/FEFW-Stable-with-60-FPS-Patch/tree/source-v1.6.7.5-test44) | see `SHA256.txt` |
| `FEFW-Test-v1.6.7.5-test42.zip` | test41 plus: one video decoder thread per session (#22); controller rumble sent from its own thread (#36); on low-memory cards, cleanup no longer copies back images used in the last 2 s (#35). Source: [`source-v1.6.7.5-test42`](https://github.com/TheSneakyBadger/FEFW-Stable-with-60-FPS-Patch/tree/source-v1.6.7.5-test42) | see `SHA256.txt` |
| `FEFW-Test-v1.6.7.5-test41.zip` | v1.6.7.4 plus: video decoder calls on their own thread, for the cutscene slowdown (#22); HDR paper white setting (#33); updater resumes dropped downloads (#32); the old 60fps add-on moves to the 60 FPS mode setting. Source: [`source-v1.6.7.5-test41`](https://github.com/TheSneakyBadger/FEFW-Stable-with-60-FPS-Patch/tree/source-v1.6.7.5-test41) | see `SHA256.txt` |
| `FEFW-Test-v1.6.7.3-test7.zip` | #22: test6 plus wait statistics. Started with `EDEN_BACK_THREAD_STATS=1`, it logs every 10 s what the game's rendering and movie threads were blocked on, and how long each emulator service took | see `SHA256.txt` |
