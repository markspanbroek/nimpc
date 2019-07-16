import tables
import bigints
include Parties

type
  Inbox = ref Table[Party, BigInt]
  Inboxes = ref Table[Party, Inbox]

var inboxes = Inboxes()

proc inbox(party: Party): Inbox =
  if not inboxes.hasKey(party):
    inboxes[party] = Inbox()
  result = inboxes[party]

method send*(sender: Party, recipient: Party, value: BigInt) {.base.} =
  recipient.inbox[sender] = value

method receive*(recipient: Party, sender: Party): BigInt {.base.} =
  if recipient.inbox.hasKey(sender):
    result = recipient.inbox[sender]
