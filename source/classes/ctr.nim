import console
export console

type
    CTR* = ref object of Console

method console_name(self: CTR) : string =
    return "Nintendo 3DS"

method compile(self: CTR) =
    echo self.console_name
