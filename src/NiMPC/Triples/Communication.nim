import asyncdispatch
import ../SecretSharing
import ../SecretSharing/Internals
import ../Communication
export Communication

proc receiveShare*(receiver: LocalParty, sender: Party):
                    Future[Share] {.async.} =
  result = await receive[Share](receiver, sender)

proc receiveShares*(receiver: LocalParty, sender: Party):
                    Future[seq[Share]] {.async.} =
  result = await receive[seq[Share]](receiver, sender)
