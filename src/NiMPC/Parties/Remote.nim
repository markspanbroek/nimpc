import asyncdispatch
import asyncnet
import strutils
import Basics
import Envelopes

type RemoteParty* = ref object of Party
  socket: AsyncSocket

proc newRemoteParty*(identity: Identity): RemoteParty =
  new(result)
  init(result, identity)

method connect*(party: RemoteParty, host: string, port: Port) {.async,base.} =
  assert party.socket == nil
  party.socket = newAsyncSocket()
  await party.socket.connect(host, port)

method disconnect*(party: RemoteParty) {.base.} =
  assert party.socket != nil
  party.socket.close()

method acceptDelivery*(receiver: RemoteParty,
                       sender: Party,
                       message: SealedEnvelope) {.async.} =
  await receiver.socket.send($message & "\n")
