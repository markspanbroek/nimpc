import Basics
import Envelopes

proc checkSenderId(party: Party, senderId: Identity): bool =
  try:
    discard party.peers[senderId]
    return true
  except IndexError:
    return false

proc checkRecipientId(party: Party, recipientId: Identity): bool =
  return party.id == recipientId

proc checkEnvelope*(party: Party, envelope: SealedEnvelope): bool =
  return
    party.checkSenderId(envelope.senderId) and
    party.checkRecipientId(envelope.recipientId)
