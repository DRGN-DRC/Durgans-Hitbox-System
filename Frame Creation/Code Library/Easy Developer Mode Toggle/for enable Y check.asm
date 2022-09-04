# To be inserted at 0x801A1CC8

# for enable Y check
bEnableY = 30  # enable Y hotkey for debug menu?
eq = 2

crnot eq, bEnableY
beq+ _return
# override cr0 eq with bEnableY

  _default:
  rlwinm.    r0, r31, 0, 20, 20
  # if enabled, then default comparison is made, else override takes precidence

_return:
.long 0