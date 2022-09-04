# To be inserted at devtoggle_settings

# devmode OFF settings:
.long  2         # fog type
.float 80.0      # Z Depth of fog color start (no color)
.float 300.0     # Z Depth of fog color end (full color)
.long 0x262626FF # background color
.long 0xB5 # SFX ID

# devmode ON settings:
.long  6         # fog type
.float -16.0     # Z Depth of fog color start (no color)
.float  64.0     # Z Depth of fog color end (full color)
.long 0xE0A020FF # background color
.long 0x12B # SFX ID

# 0x28: other settings:
.byte restore | enableX | devstate | quickkey | color
# combine any of the boolean options together with '|'
.align 2

# boolean option names:
restore   = 1    # restore devmode state from memory card?
enableY   = 2    # enable Y hotkey for debug menu?
enableX   = 4    # enable X hotkey for sound test menu?
enableA   = 8    # enable A hotkey for debug quick match?
timestamp = 16   # enable timestamp display in developer mode?
devstate  = 32   # enable devmode requirement for hotkeys and timestamp?
quickkey  = 64   # enable quick developer mode toggle with custom hotkey?
color     = 128  # enable background color changes to indicate devmode state?

# 0x2C: Quick devmode hotkey button masks:

.long 0x00020200 # pressing EQ mask
# ex: 0x00020200 = down + B
# -- these buttons must be all pressed when trigger is pressed to trigger hotkey logic

.long 0x00000200 # trigger  OR mask
# ex: 0x00000200 = B
# -- if EQ mask is true, and any of these trigger buttons have just been pressed, trigger hotkey

# 0x34: Demo transition timer threshold:
.long 0
# set this to any number below 60 to disable