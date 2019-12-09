import asyncdispatch
import ../SecretSharing
import ../SecretSharing/Internals
import ../Communication
export Communication

proc receiveShare*(recipient: LocalParty, sender: Party):
                    Future[Share] {.async.} =
  result = await receive[Share](recipient, sender)

proc receiveShares*(recipient: LocalParty, sender: Party):
                    Future[seq[Share]] {.async.} =
  result = await receive[seq[Share]](recipient, sender)
