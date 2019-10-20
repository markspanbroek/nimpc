import unittest
import asynctest
import http
import NiMPC/Parties/Basics
import NiMPC/Parties/Remote

let host = "localhost"
let port = Port(34590)

suite "remote parties":

  test "they exist":
    check RemoteParty() != nil

  test "they forward messages over a socket":
    proc receiving {.async.} =
      check (await receive(host, port)) == "onetwo"

    proc sending {.async.} =

      let party = RemoteParty()
      await party.connect(host, port)
      defer: party.disconnect()

      await party.acceptDelivery(Party(), "one")
      await party.acceptDelivery(Party(), "two")

    waitFor all(receiving(), sending())

  test "cannot disconnect when not connected":
    expect Exception:
      RemoteParty().disconnect()

  test "cannot connect twice":
    proc receiving {.async.} =
      discard await receive(host, port)

    proc sending {.async.} =

      let party = RemoteParty()
      await party.connect(host, port)
      defer: party.disconnect()

      expect Exception:
        await party.connect(host, port)

    waitFor all(receiving(), sending())
