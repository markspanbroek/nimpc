import unittest
import asynctest
import strutils
import http
import NiMPC/Parties/Basics
import NiMPC/Parties/Remote

suite "remote parties":

  test "cannot disconnect when not connected":
    expect Exception:
      newRemoteParty().disconnect()

suite "connected remote parties":

  let host = "localhost"
  let port = Port(34590)

  var party: RemoteParty
  var sender: Party
  var received: Future[string]

  asyncsetup:
    party = newRemoteParty()
    sender = newParty()
    received = receive(host, port)
    await party.connect(host, port)

  asyncteardown:
    discard await received

  asynctest "forward messages over a socket":
    await party.acceptDelivery(sender, "one")
    await party.acceptDelivery(sender, "two")
    party.disconnect()

    check (await received).contains("one")
    check (await received).contains("two")

  asynctest "cannot connect twice":
    defer: party.disconnect()
    expect Exception:
      await party.connect(host, port)

  asynctest "envelope contains sender":
    await party.acceptDelivery(sender, "some message")
    party.disconnect()

    check (await received).contains($sender.id)
