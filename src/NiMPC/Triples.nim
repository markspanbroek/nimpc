import asyncdispatch
import Parties
import SecretSharing

type Triple = tuple[a, b, c: Secret]

proc triple*(party: Party): Future[Triple] {.async.} =
  result.a = Secret(party: party, share: 1)
  result.b = Secret(party: party, share: 1)
  result.c = Secret(party: party, share: uint64(party.peers.len + 1))
