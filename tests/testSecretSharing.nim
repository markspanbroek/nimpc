import unittest
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
  discard await party2.open(secret2)

asynctest "generates different random numbers":
  let party = Party()
  let secret1, secret2 = random()
  check (await party.open(secret1)) != (await party.open(secret2))

asynctest "shares a secret":
  let party1, party2 = Party()
  connect(party1, party2)
  let secret2 = await party2.obtain(party1)
  let secret1 = await party1.share(42)
  await party1.reveal(secret1, party2)
  let opened = await party2.open(secret2)
  check opened == 42
