import asyncdispatch
import asyncnet
import Basics

type RemoteParty* = ref object of Party
  socket: AsyncSocket

method connect*(party: RemoteParty, host: string, port: Port) {.async,base.} =
  party.socket = newAsyncSocket()
  await party.socket.connect(host, port)

method disconnect*(party: RemoteParty) {.base.} =
  assert party.socket != nil
  party.socket.close()

method acceptDelivery*(receiver: RemoteParty,
                       sender: Party,
                       message: string) {.async.} =
  await receiver.socket.send(message)
