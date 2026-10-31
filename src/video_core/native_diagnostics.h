// SPDX-FileCopyrightText: Copyright 2026 Eden Emulator Project
// SPDX-License-Identifier: GPL-3.0-or-later
#pragma once

#include <atomic>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <filesystem>

namespace VideoCommon {
inline bool NativeDrawDiagnosticsEnabled() {
    static const bool enabled = std::getenv("EDEN_NATIVE_DRAW_DIAGNOSTICS") != nullptr;
    return enabled;
}
// EDEN_NATIVE_TEXTURE_REQUESTS: only the request-driven readbacks (native-gpu-texture.request,
// native-dispatch-trace.request, native-draw-ps.request), without the rest of the draw diagnostics,
// which slow the game to a few fps.
inline bool NativeTextureRequestsEnabled() {
    static const bool enabled =
        NativeDrawDiagnosticsEnabled() || std::getenv("EDEN_NATIVE_TEXTURE_REQUESTS") != nullptr;
    return enabled;
}
inline bool NativeFrameCaptureEnabled() {
    static const bool enabled = std::getenv("EDEN_NATIVE_FRAME_CAPTURE") != nullptr;
    return enabled;
}
inline bool NativeDrawCaptureEnabled() {
    static const bool enabled = std::getenv("EDEN_NATIVE_DRAW_CAPTURE") != nullptr;
    return enabled;
}
// True when a "*.request" file may be waiting in the working directory. The directory is scanned at
// most every 100 ms; checking each request file on every draw and dispatch slowed diagnostic runs to
// about 1 fps. A request is therefore picked up up to 100 ms late.
inline bool NativeRequestPending() {
    using Clock = std::chrono::steady_clock;
    static std::atomic<Clock::rep> next_scan{};
    static std::atomic<bool> pending{};
    const Clock::rep now = Clock::now().time_since_epoch().count();
    Clock::rep due = next_scan.load(std::memory_order_relaxed);
    if (now >= due && next_scan.compare_exchange_strong(
                          due, now + std::chrono::duration_cast<Clock::duration>(
                                         std::chrono::milliseconds(100)).count())) {
        // Known names only: run directories hold thousands of dump files, too many to list often.
        static constexpr const char* names[] = {
            "native-gpu-texture.request", "native-dispatch-trace.request",
            "native-dlss-snapshot.request", "native-draw-ps.request", "native-draw.request",
            "native-twin.request", "native-zero.request", "native-layer-dump.request",
            "native-display-texture.request",
            "native-window-draw.request",
            "native-compute.request", "native-memory.request", "native-textures.request",
        };
        bool found = false;
        std::error_code error;
        for (const char* name : names) {
            if (std::filesystem::exists(name, error)) {
                found = true;
                break;
            }
        }
        pending.store(found, std::memory_order_relaxed);
    }
    return pending.load(std::memory_order_relaxed);
}
// Remaining compute dispatches whose grid/kind is logged (armed by native-dispatch-trace.request).
inline std::atomic<std::uint32_t>& NativeDispatchDimsBudget() {
    static std::atomic<std::uint32_t> budget{};
    return budget;
}
} // namespace VideoCommon
