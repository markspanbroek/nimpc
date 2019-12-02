import asyncdispatch
import asyncnet
import json
import sequtils
import Local

type
  Listener* = ref object
    socket: AsyncSocket
    future: Future[void]

proc acceptOrClosed(socket: AsyncSocket): Future[AsyncSocket] {.async.} =
  try:
    result = await socket.accept()
  except OSError as error:
    if not socket.isClosed:
      raise error

proc closeSafely(socket: AsyncSocket) =
  if not socket.isClosed:
    socket.close()

proc acceptEnvelope(party: LocalParty, envelope: string) {.async.} =
  let parsed = parseJson(envelope)
  let message = parsed["message"].getStr()
  let senderId = parsed["sender"].getStr()
  let sender = party.peers.filterIt($it.id == senderId)[0]
  await party.acceptDelivery(sender, message)

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
