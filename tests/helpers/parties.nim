import sequtils
import asyncdispatch
import NiMPC/Parties

template run(statements) =
  var computations {.inject.} : seq[proc: Future[void]]
  statements
  waitFor all(mapIt(computations, it()))

template computation*(statements) =
  let asyncproc = proc {.async.} = statements
  computations.add(asyncproc)

template singleParty*(statements) =
  let party {.inject.} = newLocalParty()
  statements

template twoParties*(statements) =
  let party1 {.inject.}, party2 {.inject.} = newLocalParty()
  connect(party1, party2)
  run(statements)

template threeParties*(statements) =
  let party1 {.inject.}, party2 {.inject.}, party3 {.inject.} = newLocalParty()
  connect(party1, party2, party3)
  run(statements)
