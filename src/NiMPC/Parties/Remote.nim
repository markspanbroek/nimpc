import asyncdispatch
import asyncnet
import strutils
import Basics
import Connections
import Envelopes

type RemoteParty* = ref object of Party
  socket: AsyncSocket

proc newRemoteParty*(identity: Identity): RemoteParty =
  new(result)
  init(result, identity)

method connect*(party: RemoteParty, host: string, port: Port) {.async,base.} =
  assert party.socket == nil
  var connected = false
  while not connected:
    party.socket = newAsyncSocket()
    try:
      await party.socket.connect(host, port)
      connected = true
    except OSError:
      await sleepAsync(1000)

proc connect*(party: Party, id: Identity, host: string, port: Port): Future[RemoteParty] {.async.} =
  result = newRemoteParty(id)
  party.connect(result)
  await result.connect(host, port)

method disconnect*(party: RemoteParty) {.base.} =
  assert party.socket != nil
  party.socket.close()

method acceptDelivery*(recipient: RemoteParty,
                       sender: Party,
                       message: SealedEnvelope) {.async.} =
  await recipient.socket.send($message & "\n")
