import tables
import asyncdispatch
import Parties
export Parties

type
  Messages = FutureStream[uint32]
  Inbox = ref Table[Party, Messages]
  Inboxes = ref Table[Party, Inbox]

var inboxes = Inboxes()

proc inbox(recipient: Party): Inbox =
  inboxes.mgetOrPut(recipient, Inbox())

proc messagesFrom(inbox: Inbox, sender: Party): Messages =
  inbox.mgetOrPut(sender, newFutureStream[uint32]())

method send*(sender: Party, recipient: Party, value: uint32): Future[void] {.async,base.} =
  let messages = recipient.inbox.messagesFrom(sender)
  await messages.write(value)

method broadcast*(sender: Party, value: uint32): Future[void] {.async,base.} =
  for recipient in sender.peers:
    await sender.send(recipient, value)

method receive*(recipient: Party, sender: Party): Future[uint32] {.async,base.} =
  let messages = recipient.inbox.messagesFrom(sender)
  let (_, received) = await messages.read()
  result = received
