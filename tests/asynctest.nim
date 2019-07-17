import asyncdispatch

template asynctest*(name, body) =
  test name:
    let asyncproc = proc {.async.} = body
    waitFor asyncproc()
