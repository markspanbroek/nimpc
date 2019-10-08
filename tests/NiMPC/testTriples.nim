import unittest
import asynctest
import parties
import NiMPC/Parties
import NiMPC/Triples

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
      twoParties:
        computation:
          let triple = await party1.triple()
          (a, b, c) = await triple.open()
        computation:
          let triple = await party2.triple()
          await triple.disclose()
      result = (a, b, c)

    asynctest "generates a correct triple":
      let (a,b,c) = await createAndOpenTriple()
      check a * b == c

    asynctest "generates random triples":
      let triple1 = await createAndOpenTriple()
      let triple2 = await createAndOpenTriple()
      check triple1 != triple2

  suite "more than two parties":

    proc createAndOpenTriple(): Future[tuple[a, b, c: uint32]] {.async.} =
      var a, b, c: uint32
      threeParties:
        computation:
          let triple = await party1.triple()
          (a, b, c) = await triple.open()
        computation:
          let triple = await party2.triple()
          await triple.disclose()
        computation:
          let triple = await party3.triple()
          await triple.disclose()
      result = (a, b, c)

    asynctest "generates a correct triple":
      let (a,b,c) = await createAndOpenTriple()
      check a * b == c
