import Basics
import asyncstreams
import asyncdispatch
import asyncnet
import json
import tables
import sequtils
import sysrandom
import monocypher
export Basics

type
  Messages = FutureStream[string]
  Inbox = Table[Party, Messages]
  LocalParty* = ref object of Party
    inbox: Inbox
    secretKey*: Key
  Listener* = ref object
    socket: AsyncSocket

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

proc acceptOrClosed(socket: AsyncSocket): Future[AsyncSocket] {.async.} =
  try:
    result = await socket.accept()
  except OSError as error:
    if not socket.isClosed:
      raise error

proc closeSafely(socket: AsyncSocket) =
  if not socket.isClosed:
    socket.close()

proc handleConnection(party: LocalParty, connection: AsyncSocket) {.async.} =
  defer: connection.close()
  while not connection.isClosed:
    let envelope = await connection.recvLine()
    if envelope != "":
      let parsed = parseJson(envelope)
      let message = parsed["message"].getStr()
      let senderId = parsed["sender"].getStr()
      let sender = party.peers.filterIt($it.id == senderId)[0]
      await party.acceptDelivery(sender, message)

proc listen*(party: LocalParty, host: string, port: Port): Listener =
  new(result)
  let listener = result
  proc doit {.async.} =
    let socket = newAsyncSocket()
    defer: socket.closeSafely()
    socket.setSockOpt(OptReuseAddr, true)
    socket.bindAddr(port, host)
    socket.listen()
    listener.socket = socket
    while not socket.isClosed:
      let connection = await socket.acceptOrClosed()
      if not socket.isClosed:
        asyncCheck party.handleConnection(connection)
  asyncCheck doit()

proc stop*(listener: Listener) {.async.} =
  listener.socket.close()
