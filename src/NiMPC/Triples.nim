import Parties
import SecretSharing

type Triple = tuple[a, b, c: Secret]

proc triple*(party: Party): Triple =
  result.a = Secret(party: party, share: 1)
  result.b = Secret(party: party, share: 1)
  result.c = Secret(party: party, share: uint32(party.peers.len + 1))
  
