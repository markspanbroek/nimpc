import asyncdispatch
import asyncnet
import json
import sequtils
import Identity
import Local
import Sockets

type
  Listener* = ref object
    socket: AsyncSocket
    future: Future[void]
  Envelope = object
    senderId: Identity
    receiverId: Identity
    message: string

proc parseEnvelope(s: string): Envelope =
  let json = parseJson(s)
  result.message = json["message"].getStr()
  result.senderId = parseIdentity(json["sender"].getStr())
  result.receiverId = parseIdentity(json["receiver"].getStr())

proc acceptEnvelope(party: LocalParty, envelope: string) {.async.} =
  let parsed = parseEnvelope(envelope)
  let possibleSenders = party.peers.filterIt(it.id == parsed.senderId)
  if parsed.receiverId == party.id and possibleSenders.len > 0:
    let sender = possibleSenders[0]
    await party.acceptDelivery(sender, parsed.message)

proc handleConnection(party: LocalParty, connection: AsyncSocket) {.async.} =
  defer: connection.close()
  while not connection.isClosed:
    let envelope = await connection.recvLine()
    if envelope != "":
      await party.acceptEnvelope(envelope)

proc newListener(socket: AsyncSocket, future: Future[void]): Listener =
  new(result)
  result.socket = socket
  result.future = future

proc listen(party: LocalParty, socket: AsyncSocket) {.async.} =
  defer: socket.closeSafely()
  while not socket.isClosed:
    let connection = await socket.acceptOrClosed()
    if not socket.isClosed:
      asyncCheck party.handleConnection(connection)

proc listen*(party: LocalParty, host: string, port: Port): Listener =
  let socket = newAsyncSocket()
  socket.setSockOpt(OptReuseAddr, true)
  socket.bindAddr(port, host)
  socket.listen()
  let future = party.listen(socket)
  result = newListener(socket, future)

proc stop*(listener: Listener) {.async.} =
  listener.socket.close()
  await listener.future
