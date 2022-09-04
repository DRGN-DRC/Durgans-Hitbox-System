# To be inserted at 0x801A1CE8

# for enable A check
bEnableA = 28  # enable A hotkey for debug quick match?
eq = 2

crnot eq, bEnableA
beq+ _return
# override cr0 eq with bEnableA

  _default:
  rlwinm.    r0, r31, 0, 23, 23
  # if enabled, then default comparison is made, else override takes precidence

_return:
.long 0