import asyncdispatch
import asyncnet
import Local
import Sockets
import Envelopes
import CheckEnvelope

type
  Listener* = ref object
    socket: AsyncSocket
    future: Future[void]

proc acceptEnvelope(party: LocalParty, envelope: string) {.async.} =
  var parsed: SealedEnvelope
  try: parsed = parseSealedEnvelope(envelope) except ValueError: return
  if party.checkEnvelope(parsed):
    let sender = party.peers[parsed.senderId]
    await party.acceptDelivery(sender, parsed)

proc handleConnection(party: LocalParty, connection: AsyncSocket) {.async.} =
  defer: connection.close()
  while true:
    let envelope = await connection.recvLine()
    if envelope == "": break
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
