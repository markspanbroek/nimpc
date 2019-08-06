import unittest
import sequtils
import NiMPC/Random
import NiMPC/SecretSharing
import NiMPC/ObliviousTransfer
import NiMPC/Triples/Conversion

test "converts key to share":
  let key = random[Key]()
  check toShare(key) == cast[Share](key)

test "converts sequence of keys to shares":
  let keys = repeat(random[Key](), 2)
  check toShares(keys) == keys.mapIt(it.toShare())
