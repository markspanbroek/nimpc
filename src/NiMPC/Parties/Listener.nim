import asyncdispatch
import asyncnet
import json
import sequtils
import Local

type
  Listener* = ref object
    socket: AsyncSocket

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

proc newListener(socket: AsyncSocket): Listener =
  new(result)
  result.socket = socket

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
  asyncCheck party.listen(socket)
  result = newListener(socket)

proc stop*(listener: Listener) =
  listener.socket.close()
