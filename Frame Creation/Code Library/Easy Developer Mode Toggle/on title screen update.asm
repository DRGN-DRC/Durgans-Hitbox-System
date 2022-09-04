# To be inserted at 0x801A1C2C

# on title screen update

# registers
rParams = 12; rMode = 11; rMem = 10; rData = 9

# bools:
bMode = 21; bNoToggle = 22; bNoSound = 23; bColor = 24; bQuickKey = 25; bRestore = 31; eq = 2

lis r0, <<devtoggle_settings>>@h
ori r12, r0, <<devtoggle_settings>>@l
mr r31, r3
lis r3, 0x8048
lwz rMem, -0x77C0(r13)
lwz r0, 0x80479D60@l -0x10000(r3)
lbz rData, 0x1CD4 + (266<<1) (rMem)
cmpwi r0, 0
lwz rMode, -0x6C98(r13)
lbz r0, 0x28(rParams)
mtcrf 0x07, r0
bgt+ _check_toggling
# rMode   = devmode game state value
# rParams = parameter data from <devtoggle_settings>
# rMem    = memorycard region base
# rData   = trophy 266 padding bits from memorycard
# cr5 has been cleared
# cr6 and cr7 hold our rParam bools; and will continue to hold them for duration of host func

# if this is the first frame of the scene, then update the display and game state without hotkeys

    _initial_frame:
    andi. r4, rData, 4
    crnot bNoSound, bNoSound
    bf+ bRestore, _update
    # if game has alrady loaded static devmode value
    # avoid reloading it to prevent conflicts with other codes that modify game state

      _initial_load:
      crnot bRestore, bRestore
      mr rMode, r4
      mfcr r0
      stb r0, 0x28(rParams)
      b _update
      # else, apply 1-time memory card retrieval of state for this runtime
      # this is only done once per power-on


_check_toggling:
bf- bQuickKey, _return
# if quick developer mode toggle hotkey is disabled, then don't check for it

lis r0, 0x804C1FAC@h
ori r3, r0, 0x804C1FAC@l
lwz r5, 0x0(r3)
lwz r6, 0x2C(rParams)
lwz r4, 0x8(r3)
lwz r7, 0x30(rParams)
and. r4, r4, r7   # cr0 = is trigger false?
cmpw cr1, r5, r6  # cr1 = is pressing mask EQ?
crorc bNoToggle, eq, eq+4  # bNoToggle = trigger is false or (pressing mask is NOT EQ)
bt+ bNoToggle, _return
# if hotkey combination is not being pressed, or trigger is not being pressed this frame
# then skip to end of code

  _if_toggling:
  li r0, 4
  xor. rMode, rMode, r0
  # xor handles toggle logic

  _update:
  rlwimi rData, rMode, 0, 4
  rlwinm rMode, rMode, 0, 4
  # rMode = value ready to store in devmode variable
  # rData = value ready to store in memorycard
  # cr0 = comparison of rMode to 0

  beq+ 0x8
    addi rParams, rParams, 0x14
    # select different parameters for OFF/ON

  stw rMode, -0x6C98(r13)
  stb rData, 0x1CD4 + (266<<1) (rMem)
  # devmode has been toggled, and state has been memorized

  lwz r3, -0x3e74(r13)
  lwz r0, 0x0(rParams)
  lwz r4, 0xC(r3)
  lwz r3, 0x10(rParams)
  lwz r4, 0x28(r4)
  # r3 = SFX ID
  # r4 = title screen fog object

  bf- bColor, _playSound
  # if not updating background color, then skip to sound

    stw r0, 0x8(r4)            # update fog type
    psq_l f0, 0x4(rParams), 0, 0
    lwz r5, 0xC(rParams)
    psq_st f0, 0x10(r4), 0, 0  # update fog depth range
    stw r5, 0x18(r4)           # update color
    # Fog object has been updated

  _playSound:
  bt- bNoSound, _return
    li r4, 0xFF
    li r5, 0x80
    li r6, 0
    li r7, 7
    bl 0x8038cff4
    # play sound effect if bNoSound is still cleared
    # we only play sounds when using hotkeys to update the main menu state

_return:
mr r3, r31
bl    0x801A36A0
.long 0