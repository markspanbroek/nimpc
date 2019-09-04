import Basics
import asyncstreams
import asyncdispatch
import tables
import marshal

type
  Messages = FutureStream[string]
  Inbox = Table[Party, Messages]
  LocalParty* = ref object of Party
    inbox: Inbox

proc messagesFrom(inbox: var Inbox, sender: Party): Messages =
  inbox.mgetOrPut(sender, newFutureStream[string]())

method acceptDelivery*(recipient: LocalParty,
                       sender: Party,
                       message: string) {.async.} =
  let messages = recipient.inbox.messagesFrom(sender)
  await messages.write(message)

proc receiveMessage*(recipient: LocalParty,
                     sender: Party): Future[string] {.async.} =
  let messages = recipient.inbox.messagesFrom(sender)
  let (_, received) = await messages.read()
  result = received
