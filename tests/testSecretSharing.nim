import unittest
import asyncdispatch
import asynctest
import bigints
import NiMPC

test "generates a random secret":
  discard random()

asynctest "opens a shared random value":
  let party1, party2 = Party()
  connect(party1, party2)
  let secret1, secret2 = random()
  await party1.reveal(secret1, party2)
  discard await party2.obtain(secret2)

asynctest "generates different random numbers":
  let party = Party()
  let secret1, secret2 = random()
  check (await party.obtain(secret1)) != (await party.obtain(secret2))
