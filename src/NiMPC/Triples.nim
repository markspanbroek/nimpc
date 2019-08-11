import asyncdispatch
import sequtils
import Parties
import SecretSharing
import SecretSharing/Internals
import ObliviousTransfer
import Triples/Conversion
import Triples/Math
import Triples/Communication
import LocalRandom
import Random

type Triple* = tuple[a, b, c: Secret]

proc createDummyTriple(party: Party): Future[Triple] {.async.} =
  let count = Share(party.peers.len + 1)
  let shareA = Share(1)
  let shareB = Share(2)
  let shareC = Share(count * 2)
  result.a = Secret(party: party, share: shareA)
  result.b = Secret(party: party, share: shareB)
  result.c = Secret(party: party, share: shareC)

proc createObliviousTriple(party: Party): Future[Triple] {.async.} =

  # Implementation of the protocol from the SPDZ2k paper:
  # https://eprint.iacr.org/2018/482.pdf, Figure 12

  const 𝛕 = 192'u
  
  let Pi = party
  let Pj = party.peers[0]

  var q0, q1, sij: seq[Key]
  var ai: seq[bool]

  if Pi < Pj:
    (q0, q1) = await Pi.sendOT(Pj, 𝛕)
    (ai, sij) = await Pi.receiveOT(Pj, 𝛕)    
  else:
    (ai, sij) = await Pi.receiveOT(Pj, 𝛕)
    (q0, q1) = await Pi.sendOT(Pj, 𝛕)

  let bi = random[Share]()

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

  let ci = ai * bi + cij + cji

  # shared sequence of random variables
  let rClosed = newSeqWith(int(𝛕), await party.random())
  var r: seq[Share]
  for element in rClosed:
    await element.reveal()
    r &= await element.openSumOfShares()

  var shareA, shareB, shareC: Share = 0
  for h in 0..<𝛕:
    shareA += ai[h] * r[h]
  shareB = bi
  for h in 0..<𝛕:
    shareC += ci[h] * r[h]

  result.a = Secret(party: party, share: shareA)
  result.b = Secret(party: party, share: shareB)
  result.c = Secret(party: party, share: shareC)

proc triple*(party: Party): Future[Triple] {.async.} =
  if party.peers.len == 0:
    result = await party.createDummyTriple()
  else:
    result = await party.createObliviousTriple()
