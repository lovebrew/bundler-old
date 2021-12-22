import os

# Merge same-name globals
switch("passC", "-fcommon")
# Build statically - may throw a warning
when defined(Windows) or defined(Linux):
    switch("passL", "-static")
# Strip symbols
switch("passL", "-s")
# Change to release mode
switch("d", "release")
