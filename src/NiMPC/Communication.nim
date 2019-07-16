import bigints

type Party* = ref object

method send*(sender: Party, recipient: Party, value: BigInt) =
  discard
