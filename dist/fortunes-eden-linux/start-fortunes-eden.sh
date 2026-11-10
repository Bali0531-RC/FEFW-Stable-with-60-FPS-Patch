#!/bin/sh
# Start Fortune's Eden from this folder, so it uses the "user" folder next to it.
cd "$(dirname "$0")" || exit 1
exec ./Fortunes-Eden.AppImage "$@"
