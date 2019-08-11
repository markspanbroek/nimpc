import unittest
import asynctest
import parties
import NiMPC/Parties
import NiMPC/SecretSharing
import NiMPC/Random

suite "shared random numbers":

  asynctest "generates different random numbers":
    singleParty:
      let secret1, secret2 = party.random()
      check (await secret1.open()) != (await secret2.open())
