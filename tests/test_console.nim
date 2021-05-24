import unittest
import classes/hac
import classes/ctr

test "Switch Console Tests":
    var switch = HAC(name: "my game", author: "me", description: "cool", version: "1.2")
    check switch.getOutputName == "my game.nro"

test "3DS Console Tests":
    var ctr = CTR(name: "my game", author: "me", description: "cool", version: "1.2")
    check ctr.getName == "Nintendo 3DS"
    check ctr.getOutputName == "my game.3dsx"
