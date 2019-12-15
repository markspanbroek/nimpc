import unittest
import NiMPC
import asyncdispatch

suite "examples from Readme":

  test "local computation works":

    let party1, party2 = newLocalParty()
    defer: destroy(party1, party2)

    connect(party1, party2)

    proc computation1 {.async.} =
      let input1: Secret = party1.share(21)
      let input2: Secret = party1.obtain(party2)
      let product: Secret = input1 * input2
      let revealed: uint32 = await product.reveal() # equals 42

      check revealed == 42

    proc computation2 {.async.} =
      let input1: Secret = party2.obtain(party1)
      let input2: Secret = party2.share(2)
      let product: Secret = input1 * input2
      let revealed: uint32 = await product.reveal() # equals 42

      check revealed == 42

    waitFor all(computation1(), computation2())

  test "remote computation works":

    let party1, party2 = newLocalParty()
    defer: destroy(party1, party2)

    const host = "localhost"
    const port1 = Port(23455)
    const port2 = Port(23456)

    proc computation1 {.async.} =
      let listener = party1.listen(host, port1)
      defer: await listener.stop()

      let proxy2 = await party1.connect(party2.id, host, port2)
      defer: proxy2.disconnect()

      let input1 = party1.share(21)
      let input2 = party1.obtain(proxy2)
      let product = input1 * input2
      let revealed = await product.reveal() # equals 42

      check revealed == 42

    proc computation2 {.async.} =
      let listener = party2.listen(host, port2)
      defer: await listener.stop()

      let proxy1 = await party2.connect(party1.id, host, port1)
      defer: proxy1.disconnect()

      let input1 = party2.obtain(proxy1)
      let input2 = party2.share(2)
      let product= input1 * input2
      let revealed = await product.reveal() # equals 42

      check revealed == 42

    waitFor all(computation1(), computation2())
