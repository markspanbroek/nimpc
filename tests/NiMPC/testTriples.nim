import unittest
import asynctest
import parties
import NiMPC/Parties
import NiMPC/SecretSharing
import NiMPC/Triples

suite "multiplication triples":

  suite "single party":

    asynctest "generates a dummy triple":
      singleParty:
        let triple = await party.triple()
        check triple.a.share * triple.b.share == triple.c.share

  suite "two parties":

    proc createAndOpenTriple(): Future[tuple[a, b, c: uint32]] {.async.} =
      twoParties:
        let (fut1, fut2) = (party1.triple(), party2.triple())
        let (triple1, triple2) = (await fut1, await fut2)
        await triple2.a.reveal()
        await triple2.b.reveal()
        await triple2.c.reveal()
        result.a = await triple1.a.open()
        result.b = await triple1.b.open()
        result.c = await triple1.c.open()

    asynctest "generates a correct triple":
      twoParties:
        let (a,b,c) = await createAndOpenTriple()
        check a * b == c

    asynctest "generates random triples":
      twoParties:
        let triple1 = await createAndOpenTriple()
        let triple2 = await createAndOpenTriple()
        check triple1 != triple2
