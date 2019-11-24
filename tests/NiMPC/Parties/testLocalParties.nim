import unittest
import random
import asynctest
import strutils
import asyncdispatch
import monocypher
import NiMPC/Parties/Local
import NiMPC/Parties/Remote
import NiMPC/Communication

suite "local parties":

  test "can be created":
    check newLocalParty() != nil

  test "wipe their secret key when destroyed":
    var secretKeyPtr: ptr Key
    block:
      let party = newLocalParty()
      defer: party.destroy()
      secretKeyPtr = addr party.secretKey
    var empty: Key
    check secretKeyPtr[] == empty

suite "local parties listen for messages on a socket":

  var party1, party2: LocalParty
  var proxy1, proxy2: RemoteParty

  asyncsetup:
    party1 = newLocalParty()
    party2 = newLocalParty()
    proxy1 = newRemoteParty(party1.id)
    proxy2 = newRemoteParty(party2.id)
    connect(party1, proxy2)
    connect(party2, proxy1)
    let port = Port(rand(23000..27000))
    asyncCheck party1.listen("localhost", port)
    await proxy1.connect("localhost", port)

  teardown:
    proxy1.disconnect()

  asynctest "receives a message":
    await party2.send(proxy1, "hello")
    check (await party1.receiveString(proxy2)) == "hello"

  asynctest "receives multiple messages":
    await party2.send(proxy1, "hello")
    await party2.send(proxy1, "again")
    check (await party1.receiveString(proxy2)) == "hello"
    check (await party1.receiveString(proxy2)) == "again"
