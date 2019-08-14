import unittest
import asynctest
import parties
import NiMPC/Parties
import NiMPC/SecretSharing
import NiMPC/Random

suite "secret random numbers":

  asynctest "generates different random numbers":
    singleParty:
      let secret1, secret2 = party.random()
      check (await secret1.open()) != (await secret2.open())

suite "open random numbers":

  asynctest "generates different random numbers":
    singleParty:
      let shared1 = party.openRandom()
      let shared2 = party.openRandom()
      check (await shared1) != (await shared2)

  asynctest "each party has the same random number":
    twoParties:
      let shared1 = party1.openRandom()
      let shared2 = party2.openRandom()
      check (await shared1) == (await shared2)
