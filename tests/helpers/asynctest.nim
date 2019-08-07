import asyncdispatch
export asyncdispatch

template asynctest*(name, body) =
  test name:
    let asyncproc = proc {.async.} = body
    waitFor asyncproc()

template asyncsetup*(body) =
  setUp:
    let asyncproc = proc {.async.} = body
    waitFor asyncproc()
