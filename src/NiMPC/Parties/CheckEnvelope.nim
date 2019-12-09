import Basics
import Envelopes

proc checkSenderId(party: Party, senderId: Identity): bool =
  try:
    discard party.peers[senderId]
    return true
  except IndexError:
    return false

proc checkReceiverId(party: Party, receiverId: Identity): bool =
  return party.id == receiverId

proc checkEnvelope*(party: Party, envelope: SealedEnvelope): bool =
  return
    party.checkSenderId(envelope.senderId) and
    party.checkReceiverId(envelope.receiverId)
