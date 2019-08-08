import unittest
import sequtils
import NiMPC/LocalRandom
import NiMPC/SecretSharing/Internals
import NiMPC/ObliviousTransfer
import NiMPC/Triples/Conversion

suite "conversions for triple generation":
  
  test "converts key to share":
    let key = random[Key]()
    check toShare(key) == cast[Share](key)

  test "converts sequence of keys to shares":
    let keys = random[array[2, Key]]()
    check toShares(keys) == keys.mapIt(it.toShare())
