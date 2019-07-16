import hashes

type Party* = ref object

proc hash*(party: Party): Hash =
  result = hash(unsafeAddr party[])
