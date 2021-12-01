const DefaultConfigFile* = staticRead("assets/lovebrew.toml")

# 3DS Content and Stuff
const DefaultCtrIcon* = staticRead("assets/icon.png")

const CtrGraphics* = {
    "messagebox_single_none.t3x": staticRead("assets/ctr/graphics/messagebox_single_none.t3x"),
    "messagebox_single_pressed.t3x": staticRead("assets/ctr/graphics/messagebox_single_pressed.t3x"),
    "messagebox_two_none.t3x": staticRead("assets/ctr/graphics/messagebox_two_none.t3x"),
    "messagebox_two_pressed_left.t3x": staticRead("assets/ctr/graphics/messagebox_two_pressed_left.t3x"),
    "messagebox_two_pressed_right.t3x": staticRead("assets/ctr/graphics/messagebox_two_pressed_right.t3x")
}

# Switch Content and Stuff
const DefaultHacIcon* = staticRead("assets/icon.jpg")

const HacGraphics* = {
    "messagebox_dark_pressed.png": staticRead("assets/hac/graphics/messagebox_dark_pressed.png"),
    "messagebox_dark_two_left_pressed.png": staticRead("assets/hac/graphics/messagebox_dark_two_left_pressed.png"),
    "messagebox_dark_two_left.png": staticRead("assets/hac/graphics/messagebox_dark_two_left.png"),
    "messagebox_dark_two_none.png": staticRead("assets/hac/graphics/messagebox_dark_two_none.png"),
    "messagebox_dark_two_right_pressed.png": staticRead("assets/hac/graphics/messagebox_dark_two_right_pressed.png"),
    "messagebox_dark_two_right.png": staticRead("assets/hac/graphics/messagebox_dark_two_right.png"),
    "messagebox_dark.png": staticRead("assets/hac/graphics/messagebox_dark.png"),
    "messagebox_light_pressed.png": staticRead("assets/hac/graphics/messagebox_light_pressed.png"),
    "messagebox_light_two_left_pressed.png": staticRead("assets/hac/graphics/messagebox_light_two_left_pressed.png"),
    "messagebox_light_two_left.png": staticRead("assets/hac/graphics/messagebox_light_two_left.png"),
    "messagebox_light_two_none.png": staticRead("assets/hac/graphics/messagebox_light_two_none.png"),
    "messagebox_light_two_right_pressed.png": staticRead("assets/hac/graphics/messagebox_light_two_right_pressed.png"),
    "messagebox_light_two_right.png": staticRead("assets/hac/graphics/messagebox_light_two_right.png"),
    "messagebox_light.png": staticRead("assets/hac/graphics/messagebox_light.png")
}

const HacShaders* = {
    "color_fsh": staticRead("assets/hac/shaders/color_fsh.dksh"),
    "texture_fsh": staticRead("assets/hac/shaders/texture_fsh.dksh"),
    "transform_vsh": staticRead("assets/hac/shaders/transform_vsh.dksh")
}
