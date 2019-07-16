import tables
import bigints
import asyncdispatch
include Parties

type
  Inbox = ref Table[Party, BigInt]
  Inboxes = ref Table[Party, Inbox]

var inboxes = Inboxes()

proc inbox(party: Party): Inbox =
  inboxes.mgetOrPut(party, Inbox())

method send*(sender: Party, recipient: Party, value: BigInt): Future[void] {.async,base.} =
  recipient.inbox[sender] = value

method receive*(recipient: Party, sender: Party): Future[BigInt] {.async,base.} =
  if recipient.inbox.hasKey(sender):
    result = recipient.inbox[sender]
    recipient.inbox.del(sender)
