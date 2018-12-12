# Package

version       = "1.0"
author        = "Neal Nelson"
description   = "Diceware password generator"
license       = "MIT"
srcDir        = "src"
bin           = @["dicepass"]
skipExt       = @["nim"]

# Dependencies

requires "nim >= 0.19.0"
