import asyncdispatch
import asyncnet

proc acceptConnection(host: string, port: Port): Future[AsyncSocket] {.async.} =
  let socket = newAsyncSocket()
  defer: socket.close()
  socket.setSockOpt(OptReuseAddr, true)
  socket.bindAddr(port, host)
  socket.listen()
  return await socket.accept()

proc receive*(host: string, port: Port): Future[string] {.async.} =
  let connection = await acceptConnection(host, port)
  defer: connection.close()
  var chunk = await connection.recvLine()
  while chunk != "":
    result &= chunk
    chunk = await connection.recvLine()
