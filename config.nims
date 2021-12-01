# Merge globals with the same name, build static, strip symbols and change to release mode
# TODO: don't use -fcommon

import os

when defined(Windows) or defined(Linux):
    switch("passL", "-static")

switch("passC", "-fcommon")
switch("passL", "-s")
switch("d", "release")
