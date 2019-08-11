import sequtils
import ../SecretSharing/Internals
import ../ObliviousTransfer

proc toShare*(key: Key): Share =
  result = cast[Share](key)

proc toShares*(keys: openArray[Key]): seq[Share] =
  result = keys.mapIt(it.toShare())
