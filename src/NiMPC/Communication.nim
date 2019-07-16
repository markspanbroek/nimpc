import tables
import bigints
import asyncdispatch
include Parties

type
  Messages = FutureStream[BigInt]
  Inbox = ref Table[Party, Messages]
  Inboxes = ref Table[Party, Inbox]

var inboxes = Inboxes()

proc inbox(party: Party): Inbox =
  inboxes.mgetOrPut(party, Inbox())

method send*(sender: Party, recipient: Party, value: BigInt): Future[void] {.async,base.} =
  let messages = recipient.inbox.mgetOrPut(sender, newFutureStream[BigInt]())
  await messages.write(value)

method broadcast*(sender: Party, value: BigInt): Future[void] {.async,base.} =
  for recipient in sender.peers:
    await sender.send(recipient, value)

method receive*(recipient: Party, sender: Party): Future[BigInt] {.async,base.} =
  let messages = recipient.inbox.mgetOrPut(sender, newFutureStream[BigInt]())
  let (_, received) = await messages.read()
  result = received
