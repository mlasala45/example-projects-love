require "game/util/color"

--Window Parameters and Engine Graphics
FULLSCREEN = true
WINDOW_WIDTH = 2000*0.4
WINDOW_HEIGHT = 1374*0.4
MSAA = 4

QUALITY_SCALE = 4

--Debug Flags
DEBUG = true
DRAW_BOUNDS = false
SPLASH = false

--Colors
DEBUG_COLOR = COLORS.WHITE
DEBUG_TEXT_COLOR = COLORS.WHITE

UI_COLOR_PRIMARY = COLORS.GRAY
UI_COLOR_SECONDARY = COLORS.BLACK

CITY_UI_COLOR_PRIMARY = COLORS.DARK_GRAY
CITY_UI_COLOR_SECONDARY = { 64, 48, 117 }

--DBG
UI_COLOR_SECONDARY = CITY_UI_COLOR_SECONDARY

--Formatting
DEFAULT_TEXT_WIDTH = 130

--Game Flags
ALT_MAP_DRAW = true
JUTTER = false        --Remove movement interpolation for units
REVEAL_ALL = false