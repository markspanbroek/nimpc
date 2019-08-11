import asyncdispatch
import LocalRandom
import Parties
import SecretSharing
import SecretSharing/Internals

method random*(party: Party): Future[Secret] {.async,base.} =
  result = Secret(party: party, share: random[Share]())
