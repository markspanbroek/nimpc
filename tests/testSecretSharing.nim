import unittest
import asyncdispatch
import bigints
import NiMPC

test "it can generate a random secret":
  discard random()

test "it can open a shared random value":
  let party1 = Party()
  let party2 = Party()
  let secret1 = random()
  let secret2 = random()
  waitFor party1.reveal(secret1, party2)
  let revealed = waitFor party2.obtain(secret2)
  var zero: BigInt
  check revealed != zero

test "it generates different random numbers":
  let party = Party()
  let secret1 = random()
  let secret2 = random()
  let revealed1 = waitFor party.obtain(secret1)
  let revealed2 = waitFor party.obtain(secret2)
  check revealed1 != revealed2
