import LocalRandom
import Parties
import SecretSharing
import SecretSharing/RawShares

proc random*(party: LocalParty): Secret =
  result = party.rawShare(random[Share]())
