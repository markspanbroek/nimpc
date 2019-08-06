import tables
import asyncdispatch
import marshal
import Parties
export Parties

type
  Messages = FutureStream[string]
  Inbox = ref Table[Party, Messages]
  Inboxes = ref Table[Party, Inbox]

var inboxes = Inboxes()

proc inbox(recipient: Party): Inbox =
  inboxes.mgetOrPut(recipient, Inbox())

proc messagesFrom(inbox: Inbox, sender: Party): Messages =
  inbox.mgetOrPut(sender, newFutureStream[string]())

proc send*[T](sender: Party, recipient: Party, value: T): Future[void] {.async.} =
  let messages = recipient.inbox.messagesFrom(sender)
  await messages.write($$value)

proc broadcast*[T](sender: Party, value: T): Future[void] {.async.} =
  for recipient in sender.peers:
    await sender.send(recipient, value)

proc receive*[T](recipient: Party, sender: Party): Future[T] {.async.} =
  let messages = recipient.inbox.messagesFrom(sender)
  let (_, received) = await messages.read()
  result = to[T](received)

proc receiveUint64*(recipient: Party, sender: Party): Future[uint64] {.async.} =
  result = await receive[uint64](recipient, sender)
