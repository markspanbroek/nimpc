type Party* = ref object

method send*(sender: Party, recipient: Party, value: int) =
  discard
