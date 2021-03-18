import console
export console

type
    HAC* = ref object of Console

method console_name(self: HAC) : string =
    return "Nintendo Switch"

method compile(self: HAC) =
    echo self.console_name
