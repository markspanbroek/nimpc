import Identity
import NiMPC/Parties/Local
import NiMPC/Parties/Envelopes
import NiMPC/Parties/Encryption
export Envelopes

proc exampleSealedEnvelope*: SealedEnvelope =
  let sender = newLocalParty()
  let envelope = Envelope(
    senderId: sender.id,
    receiverId: exampleIdentity(),
    message: "example"
  )
  return sender.encrypt(envelope)
