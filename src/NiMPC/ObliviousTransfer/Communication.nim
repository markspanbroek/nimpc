import asyncdispatch
import simpleot
import ../Parties
import ../Communication
export simpleot

proc receiveSenderMessages*(recipient: Party, sender: Party): 
                            Future[seq[SenderMessage]] {.async.} =
  result = await receive[seq[SenderMessage]](recipient, sender)

proc receiveReceiverMessages*(recipient: Party, sender: Party): 
                              Future[seq[ReceiverMessage]] {.async.} =
  result = await receive[seq[ReceiverMessage]](recipient, sender)
