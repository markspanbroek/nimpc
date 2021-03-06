import asyncdispatch
import simpleot
import ../Parties
import ../Communication
export Communication

proc receiveSenderMessages*(recipient: LocalParty, sender: Party):
                            Future[seq[SenderMessage]] {.async.} =
  result = await receive[seq[SenderMessage]](recipient, sender)

proc receiveReceiverMessages*(recipient: LocalParty, sender: Party):
                              Future[seq[ReceiverMessage]] {.async.} =
  result = await receive[seq[ReceiverMessage]](recipient, sender)
