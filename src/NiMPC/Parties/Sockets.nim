import asyncnet
import asyncdispatch

proc acceptOrClosed*(socket: AsyncSocket): Future[AsyncSocket] {.async.} =
  try:
    result = await socket.accept()
  except OSError as error:
    if not socket.isClosed:
      raise error

proc closeSafely*(socket: AsyncSocket) =
  if not socket.isClosed:
    socket.close()
