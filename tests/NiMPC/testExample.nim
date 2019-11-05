import unittest
import NiMPC
import asyncdispatch

test "example from Readme works":

  let party1, party2 = newLocalParty()
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
