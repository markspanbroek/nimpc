import unittest
import asynctest
import strutils
import http
import NiMPC/Parties/Basics
import NiMPC/Parties/Remote

suite "remote parties":

  let host = "localhost"
  let port = Port(34590)

  var party: RemoteParty

  setup:
    party = newRemoteParty()

  test "forward messages over a socket":
    proc receiving {.async.} =
      let received = await receive(host, port)
      check received.contains("one")
      check received.contains("two")

    proc sending {.async.} =
      await party.connect(host, port)
      defer: party.disconnect()
      await party.acceptDelivery(newParty(), "one")
      await party.acceptDelivery(newParty(), "two")

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
      newRemoteParty().disconnect()

  test "envelope contains sender":
    let sender = newParty()

    proc receiving {.async.} =
      let received = await receive(host, port)
      check received.contains($sender.id)

    proc sending {.async.} =
      await party.connect(host, port)
      defer: party.disconnect()
      await party.acceptDelivery(sender, "some message")

    waitFor all(receiving(), sending())