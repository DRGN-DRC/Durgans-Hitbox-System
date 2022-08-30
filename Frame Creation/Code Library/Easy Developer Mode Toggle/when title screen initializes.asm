# To be inserted at 0x801A2188

# when title screen initializes
bTimestamp = 27  # enable timestamp display in developer mode?
bDevhotkey = 26  # enable devmode requirement for hotkeys and timestamp?
lt = 0

lis r12, <<devtoggle_settings>>@h
ori r12, r12, <<devtoggle_settings>>@l
lbz r12, 0x28(r12)
mtcrf 0x3, r12
# load param bools

bt+ bDevhotkey, 8
  li r0, 4
  # ignore devmode state if bDevhotkey

crnot lt, bTimestamp
blt+ _return
# override cr0 lt with bTimestamp

  _default:
  cmpwi    r0, 1
  # if enabled, the default comparison is made, else override takes precidence
  # if ignoring devmode state, then comparison will always be gt

_return:
.long 0