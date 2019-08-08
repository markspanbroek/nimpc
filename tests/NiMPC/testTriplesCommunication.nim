import unittest
import asynctest
import parties
import NiMPC/LocalRandom
import NiMPC/Triples/Communication
import NiMPC/SecretSharing
import NiMPC/SecretSharing/Internals

suite "communication for triple generation":

  asynctest "can send share":
    twoParties:
      let share = random[Share]()
      await party1.send(party2, share)
      check (await party2.receiveShare(party1)) == share

  asynctest "can send a sequence of shares":
    twoParties:
      let shares = random[array[2, Share]]()
      await party1.send(party2, shares)
      check (await party2.receiveShares(party1)) == shares
