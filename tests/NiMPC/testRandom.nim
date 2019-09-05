import unittest
import asynctest
import parties
import NiMPC/Parties
import NiMPC/SecretSharing
import NiMPC/Random

suite "secret random numbers":

  asynctest "generates different random numbers":
    singleParty:
      let shared1 = party.random().reveal()
      let shared2 = party.random().reveal()
      check (await shared1) != (await shared2)

  asynctest "each party has the same random number":
    twoParties:
      let shared1 = party1.random().reveal()
      let shared2 = party2.random().reveal()
      check (await shared1) == (await shared2)
