import asyncdispatch
import asyncnet
import json
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

proc checkSenderId(party: Party, senderId: Identity): bool =
  try:
    discard party.peers[senderId]
    return true
  except IndexError:
    return false

proc checkReceiverId(party: Party, receiverId: Identity): bool =
  return party.id == receiverId

proc checkEnvelope(party: Party, envelope: Envelope): bool =
  return
    party.checkSenderId(envelope.senderId) and
    party.checkReceiverId(envelope.receiverId)

proc acceptEnvelope(party: LocalParty, envelope: string) {.async.} =
  let parsed = parseEnvelope(envelope)
  if party.checkEnvelope(parsed):
    let sender = party.peers[parsed.senderId]
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
