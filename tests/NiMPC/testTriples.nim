import unittest
import asynctest
import parties
import NiMPC/Parties
import NiMPC/SecretSharing
import NiMPC/Triples
import NiMPC/MultipartyComputation

suite "multiplication triples":

  suite "single party":

    asynctest "generates a dummy triple":
      singleParty:
        let triple = await party.triple()
        let a = await triple.a.share
        let b = await triple.b.share
        let c = await triple.c.share
        check a * b == c

  suite "two parties":

    proc createAndOpenTriple(): Future[tuple[a, b, c: uint32]] {.async.} =
      var a, b, c: uint32
      multiparty:
        computation:
          let triple = await party.triple()
          (a, b, c) = await triple.open()
        computation:
          let triple = await party.triple()
          await triple.disclose()
      result = (a, b, c)

    asynctest "generates a correct triple":
      let (a,b,c) = await createAndOpenTriple()
      check a * b == c

    asynctest "generates random triples":
      let triple1 = await createAndOpenTriple()
      let triple2 = await createAndOpenTriple()
      check triple1 != triple2
