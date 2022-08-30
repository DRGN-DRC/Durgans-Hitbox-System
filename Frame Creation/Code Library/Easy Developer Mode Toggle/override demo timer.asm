# To be inserted at 0x801A1C5C

# override demo timer
rParams = 12
lwz r3, 0x34(rParams)
cmpwi r3, 60
bgt+ _return
  subi r0, r3, 1
  # if demo timer is less than 1 second, then disable it

_return:
cmpw r0, r3
.long 0