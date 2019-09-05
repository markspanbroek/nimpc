import asyncdispatch
import sequtils
import Parties
import SecretSharing
import SecretSharing/RawShares
import ObliviousTransfer
import Triples/Conversion
import Triples/Math
import Triples/Communication
import LocalRandom
import Random

type Triple* = tuple[a, b, c: Secret]

proc createDummyTriple(party: LocalParty): Future[Triple] {.async.} =
  let count = Share(party.peers.len + 1)
  result.a = party.rawShare(1)
  result.b = party.rawShare(2)
  result.c = party.rawShare(count * 2)

proc createObliviousTriple(party: LocalParty): Future[Triple] {.async.} =

  # Implementation of the protocol from the SPDZ2k paper:
  # https://eprint.iacr.org/2018/482.pdf, Figure 12

  const 𝛕 = 192'u

  let Pi = party

  let ai = generateChoiceBits(𝛕)
  let bi = random[Share]()

  var ci = ai * bi

  for Pj in party.peers:

    var q0, q1, sij: seq[Key]
    if Party(Pi) < Pj:
      (q0, q1) = await Pi.sendOT(Pj, 𝛕)
      sij = await Pi.receiveOT(Pj, ai)
    else:
      sij = await Pi.receiveOT(Pj, ai)
      (q0, q1) = await Pi.sendOT(Pj, 𝛕)

    var dij: seq[Share]
    for h in 0..<𝛕:
      dij &= q0[h].toShare() - q1[h].toShare() + bi

    await Pi.send(Pj, dij)
    let dji = await Pi.receiveShares(Pj)

    var tij: array[𝛕, Share]
    for h in 0..<𝛕:
      tij[h] = sij[h].toShare() + ai[h] * dji[h]

    let cij = tij
    let cji = -q0.toShares()

    ci = ci + cij + cji

  let r = newSeqWith(int(𝛕), await party.random().reveal())

  var shareA, shareB, shareC: Share = 0
  for h in 0..<𝛕:
    shareA += ai[h] * r[h]
  shareB = bi
  for h in 0..<𝛕:
    shareC += ci[h] * r[h]

  result.a = party.rawShare(shareA)
  result.b = party.rawShare(shareB)
  result.c = party.rawShare(shareC)

proc triple*(party: LocalParty): Future[Triple] {.async.} =
  if party.peers.len == 0:
    result = await party.createDummyTriple()
  else:
    result = await party.createObliviousTriple()

proc open*(triple: Triple): Future[tuple[a,b,c: uint32]] {.async.} =
  result.a = await triple.a.open()
  result.b = await triple.b.open()
  result.c = await triple.c.open()

proc disclose*(triple: Triple) {.async.} =
  await triple.a.disclose()
  await triple.b.disclose()
  await triple.c.disclose()
