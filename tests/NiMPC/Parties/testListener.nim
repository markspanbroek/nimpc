import unittest
import asynctest
import asyncdispatch
import asyncnet
import NiMPC/Parties/Local
import NiMPC/Parties/Listener
import NiMPC/Parties/Remote
import NiMPC/Communication

suite "local parties listen for messages on a socket":

  const host = "localhost"
  const port = Port(23455)

  var party1, party2: LocalParty
  var proxy1, proxy2: RemoteParty
  var listener: Listener

  asyncsetup:
    party1 = newLocalParty()
    party2 = newLocalParty()
    proxy1 = newRemoteParty(party1.id)
    proxy2 = newRemoteParty(party2.id)
    connect(party1, proxy2)
    connect(party2, proxy1)
    listener = party1.listen(host, port)
    await proxy1.connect(host, port)

  asyncteardown:
    proxy1.disconnect()
    await listener.stop()

  asynctest "receives a message":
    await party2.send(proxy1, "hello")
    check (await party1.receiveString(proxy2)) == "hello"

  asynctest "receives multiple messages":
    await party2.send(proxy1, "hello")
    await party2.send(proxy1, "again")
    check (await party1.receiveString(proxy2)) == "hello"
    check (await party1.receiveString(proxy2)) == "again"

  asynctest "receives from multiple parties":
    let party3 = newLocalParty()
    let proxy3 = newRemoteParty(party3.id)

    connect(party1, proxy3)

    await party2.send(proxy1, "hello from party 2")
    await party3.send(proxy1, "hello from party 3")
    check (await party1.receiveString(proxy2)) == "hello from party 2"
    check (await party1.receiveString(proxy3)) == "hello from party 3"

  asynctest "stops listening for incoming connections":
    await listener.stop()
    expect Exception:
      await newAsyncSocket().connect(host, port)

  asynctest "ignores unacceptable messages":
    let unknownSender = newLocalParty()
    await unknownSender.send(proxy1, "hello")

  asynctest "ignores invalid json envelopes":
    let socket = newAsyncSocket()
    defer: socket.close()
    await socket.connect(host, port)
    let wrong = "not json\n"
    await socket.send(wrong)
