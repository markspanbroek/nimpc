import asyncdispatch
import sequtils
import Parties
export asyncdispatch

proc waitFor(asyncprocs: openArray[proc: Future[void]]) =
  let futures = asyncprocs.mapIt(it())
  waitFor all(futures)

template multiparty*(statements) =
  var parties {.inject.}: seq[Party]
  var computations {.inject.}: seq[proc: Future[void]]
  statements
  connect(parties)
  waitFor computations

template computation*(statements) =
  block:
    let party {.inject} = Party()
    parties &= party
    computations &= proc {.async.} = statements
