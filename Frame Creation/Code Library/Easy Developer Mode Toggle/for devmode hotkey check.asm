# To be inserted at 0x801A1CC0

# for devmode hotkey check
bDevhotkey = 26  # enable devmode requirement for hotkeys and timestamp?
lt = 0

crmove lt, bDevhotkey
bge+ _return
# override cr0 lt with bDevhotkey

  _default:
  cmpwi    r0, 3
  # if enabled, the default comparison is made, else override takes precidence

_return:
.long 0