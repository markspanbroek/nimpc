import tables
import asyncdispatch
import marshal
import Parties/Basics
import Parties/Local
import Parties/Envelopes
import Parties/Encryption
import Parties
export Parties

proc send*[T](sender: LocalParty, recipient: Party, value: T) {.async.} =
  let envelope = Envelope(senderId: sender.id, receiverId: recipient.id, message: $$value)
  let sealed = sender.encrypt(envelope)
  await recipient.acceptDelivery(sender, sealed)

proc receive*[T](recipient: LocalParty, sender: Party): Future[T] {.async.} =
  let sealed = await receiveMessage(recipient, sender)
  let message = recipient.decrypt(sealed).message
  result = to[T](message)

proc receiveUint64*(recipient: LocalParty,
                    sender: Party): Future[uint64] {.async.} =
  result = await receive[uint64](recipient, sender)

proc receiveString*(recipient: LocalParty,
                    sender: Party): Future[string] {.async.} =
  result = await receive[string](recipient, sender)
