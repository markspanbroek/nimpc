import tables
import asyncdispatch
import marshal
import Parties/Basics
import Parties/Local
import Parties
export Parties

proc send*[T](sender: Party, recipient: Party, value: T) {.async.} =
  await recipient.acceptDelivery(sender, $$value)

proc broadcast*[T](sender: Party, value: T): Future[void] {.async.} =
  for recipient in sender.peers:
    await sender.send(recipient, value)

proc receive*[T](recipient: LocalParty, sender: Party): Future[T] {.async.} =
  let message = await receiveMessage(recipient, sender)
  result = to[T](message)

proc receiveUint64*(recipient: LocalParty,
                    sender: Party): Future[uint64] {.async.} =
  result = await receive[uint64](recipient, sender)
