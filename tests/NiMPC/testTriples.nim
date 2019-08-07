import unittest
import asynctest
import parties
import NiMPC/Parties
import NiMPC/Triples

suite "multiplication triples":

  asynctest "generates a dummy triple when there's only one party":
    singleParty:
      let triple = await party.triple()
      check triple.a.share * triple.b.share == triple.c.share
