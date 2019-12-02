import Basics
import asyncstreams
import asyncdispatch
import tables
import sysrandom
import monocypher
export Basics

type
  Messages = FutureStream[string]
  Inbox = Table[Party, Messages]
  LocalParty* = ref object of Party
    inbox: Inbox
    secretKey*: Key

proc init*(party: var LocalParty, secretKey: Key) =
  party.secretKey = secretKey
  let publicKey = crypto_sign_public_key(secretKey)
  let identity = initIdentity(publicKey)
  Party(party).init(identity)

proc destroy*(party: LocalParty) =
  crypto_wipe(party.secretKey)

proc destroy*(parties: varargs[LocalParty]) =
  for party in parties:
    destroy(party)

proc newLocalParty*(secretKey: Key = getRandomBytes(sizeof(Key))): LocalParty =
  new(result)
  init(result, secretKey)

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

