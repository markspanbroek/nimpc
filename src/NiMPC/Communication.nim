import tables
import asyncdispatch
include Parties

type
  Messages = FutureStream[uint32]
  Inbox = ref Table[Party, Messages]
  Inboxes = ref Table[Party, Inbox]

var inboxes = Inboxes()

proc inbox(party: Party): Inbox =
  inboxes.mgetOrPut(party, Inbox())

method send*(sender: Party, recipient: Party, value: uint32): Future[void] {.async,base.} =
  let messages = recipient.inbox.mgetOrPut(sender, newFutureStream[uint32]())
  await messages.write(value)

method broadcast*(sender: Party, value: uint32): Future[void] {.async,base.} =
  for recipient in sender.peers:
    await sender.send(recipient, value)

method receive*(recipient: Party, sender: Party): Future[uint32] {.async,base.} =
  let messages = recipient.inbox.mgetOrPut(sender, newFutureStream[uint32]())
  let (_, received) = await messages.read()
  result = received
