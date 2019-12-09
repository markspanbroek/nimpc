import Basics
import Envelopes
import asyncstreams
import asyncdispatch
import tables
import sysrandom
import monocypher
export Basics

type
  Messages = FutureStream[SealedEnvelope]
  Inbox = Table[Party, Messages]
  LocalParty* = ref object of Party
    inbox: Inbox
    secretKey*: Key
    peerEncryptionKeys*: Table[Identity, Key]

proc newLocalParty*(secretKey: Key = getRandomBytes(sizeof(Key))): LocalParty =
  new(result)
  result.secretKey = secretKey
  let publicKey = crypto_key_exchange_public_key(secretKey)
  let identity = initIdentity(publicKey)
  result.init(identity)

proc peerEncryptionKey*(party: LocalParty, peerId: Identity): Key =
  if party.peerEncryptionKeys.hasKey(peerId):
    result = party.peerEncryptionKeys[peerId]
  else:
    result = crypto_key_exchange(party.secretKey, Key(peerId))
    party.peerEncryptionKeys[peerId] = result

proc destroy*(party: LocalParty) =
  crypto_wipe(party.secretKey)
  for id in party.peerEncryptionKeys.keys:
    crypto_wipe(party.peerEncryptionKeys[id])

proc destroy*(parties: varargs[LocalParty]) =
  for party in parties:
    destroy(party)

proc messagesFrom(inbox: var Inbox, sender: Party): Messages =
  inbox.mgetOrPut(sender, newFutureStream[SealedEnvelope]())

method acceptDelivery*(recipient: LocalParty,
                       sender: Party,
                       message: SealedEnvelope) {.async.} =
  let messages = recipient.inbox.messagesFrom(sender)
  await messages.write(message)

proc receiveMessage*(recipient: LocalParty,
                     sender: Party): Future[SealedEnvelope] {.async.} =
  let messages = recipient.inbox.messagesFrom(sender)
  let (_, received) = await messages.read()
  result = received
