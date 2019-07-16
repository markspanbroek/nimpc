import hashes

type Party* = ref object
  peers*: seq[Party]

proc connect*(parties: varargs[Party]) =
  for party1 in parties:
    for party2 in parties:
      if party1 != party2:
        party1.peers.add(party2)
        party2.peers.add(party1)

proc hash*(party: Party): Hash =
  result = hash(unsafeAddr party[])
