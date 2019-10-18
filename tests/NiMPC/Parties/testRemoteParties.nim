import unittest
import asynctest
import asyncnet
import NiMPC/Parties/Basics
import NiMPC/Parties/Remote

suite "remote parties":

  test "they exist":
    check RemoteParty() != nil

  test "they forward messages over a socket":
    let host = "localhost"
    let port = Port(34590)

    proc receiving {.async.} =

      let socket = newAsyncSocket()
      defer: socket.close()
      socket.setSockOpt(OptReuseAddr, true)
      socket.bindAddr(port, host)
      socket.listen()

      let connection = await socket.accept()
      defer: connection.close()
      check (await connection.recvLine()) == "one"
      check (await connection.recvLine()) == "two"

    proc sending {.async.} =

      let party = RemoteParty()
      await party.connect(host, port)
      defer: party.disconnect()

      await party.acceptDelivery(Party(), "one\n")
      await party.acceptDelivery(Party(), "two\n")

    waitFor all(receiving(), sending())
