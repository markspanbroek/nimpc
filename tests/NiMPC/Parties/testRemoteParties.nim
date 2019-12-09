import unittest
import asynctest
import strutils
import http
import sysrandom
import monocypher
import examples/Envelopes
import NiMPC/Parties/Local
import NiMPC/Parties/Remote

let identity: Identity = initIdentity(getRandomBytes(sizeof(Key)))

suite "remote parties":

  test "cannot disconnect when not connected":
    expect Exception:
      newRemoteParty(identity).disconnect()

suite "connected remote parties":

  let host = "localhost"
  let port = Port(34590)

  var party: RemoteParty
  var sender: LocalParty
  var received: Future[string]

  asyncsetup:
    party = newRemoteParty(identity)
    sender = newLocalParty()
    received = receive(host, port)
    await party.connect(host, port)

  asyncteardown:
    discard await received

  asynctest "forward messages over a socket":
    let envelope1 = exampleSealedEnvelope()
    let envelope2 = exampleSealedEnvelope()

    await party.acceptDelivery(sender, envelope1)
    await party.acceptDelivery(sender, envelope2)
    party.disconnect()

    check (await received).contains($envelope1)
    check (await received).contains($envelope2)

  asynctest "cannot connect twice":
    defer: party.disconnect()
    expect Exception:
      await party.connect(host, port)

