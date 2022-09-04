# To be inserted at 0x801A1D08

# for enable X check
bEnableX = 29  # enable X hotkey for sound test menu?
eq = 2
lwz r0, -0x6C98(r13)
cmpwi r0, 0
crnor eq, eq, bEnableX
beq+ _return
# override cr0 eq with bEnableX and bMode

  _default:
  rlwinm.    r0, r31, 0, 21, 21
  # if enabled, then default comparison is made, else override takes precidence

_return:
.long 0