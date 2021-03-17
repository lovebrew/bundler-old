import console
export console

type
    HAC* = ref object of Console

method console_name(self: HAC) : string =
    return "Nintendo Switch"
