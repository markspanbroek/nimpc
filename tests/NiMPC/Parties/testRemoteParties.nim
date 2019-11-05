import unittest
import asynctest
import http
import NiMPC/Parties/Basics
import NiMPC/Parties/Remote

suite "remote parties":

  let host = "localhost"
  let port = Port(34590)

  var party: RemoteParty

  setup:
    party = initRemoteParty()

  test "forward messages over a socket":
    proc receiving {.async.} =
      check (await receive(host, port)) == "onetwo"

    proc sending {.async.} =
      await party.connect(host, port)
      defer: party.disconnect()
      await party.acceptDelivery(initParty(), "one")
      await party.acceptDelivery(initParty(), "two")

    waitFor all(receiving(), sending())

  test "cannot connect twice":
    proc receiving {.async.} =
      discard await receive(host, port)

    proc sending {.async.} =
      await party.connect(host, port)
      defer: party.disconnect()
      expect Exception:
        await party.connect(host, port)

    waitFor all(receiving(), sending())

  test "cannot disconnect when not connected":
    expect Exception:
      initRemoteParty().disconnect()
