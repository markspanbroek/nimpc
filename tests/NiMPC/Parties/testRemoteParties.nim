import unittest
import asynctest
import http
import NiMPC/Parties/Basics
import NiMPC/Parties/Remote

suite "remote parties":

  test "they exist":
    check RemoteParty() != nil

  test "they forward messages over a socket":
    let host = "localhost"
    let port = Port(34590)

    proc receiving {.async.} =
      check (await receive(host, port)) == "onetwo"

    proc sending {.async.} =

      let party = RemoteParty()
      await party.connect(host, port)
      defer: party.disconnect()

      await party.acceptDelivery(Party(), "one")
      await party.acceptDelivery(Party(), "two")

    waitFor all(receiving(), sending())
