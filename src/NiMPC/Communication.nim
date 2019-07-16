import tables
import hashes
import bigints

type Party* = ref object

proc hash*(party: Party): Hash =
  result = hash(unsafeAddr party[])

var latestValues = newTable[Party, BigInt]()

method send*(sender: Party, recipient: Party, value: BigInt) {.base.} =
  latestValues[recipient] = value

method receive*(recipient: Party, sender: Party): BigInt {.base.} =
  if latestValues.hasKey(recipient):
    result = latestValues[recipient]
