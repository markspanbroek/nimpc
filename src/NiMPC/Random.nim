import asyncdispatch
import LocalRandom
import Parties
import SecretSharing
import SecretSharing/Internals

method random*(party: Party): Secret {.base.} =
  result = party.rawShare(random[Share]())
