import unittest
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

  asynctest "receives incoming messages on a socket":
    let party1, party2 = newLocalParty()

    let proxy1 = newRemoteParty(party1.id)
    let proxy2 = newRemoteParty(party2.id)

    connect(party1, proxy2)
    connect(party2, proxy1)

    asyncCheck party1.listen("localhost", Port(23455))
    await proxy1.connect("localhost", Port(23455))
    defer: proxy1.disconnect()

    await party2.send(proxy1, "hello")
    check (await party1.receiveString(proxy2)) == "hello"
