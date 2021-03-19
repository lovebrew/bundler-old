import console
export console

type
    HAC* = ref object of Console

method getName(self : HAC) : string =
    return "Nintendo Switch"

method compile(self : HAC, source : string) =
    echo self.getName()
