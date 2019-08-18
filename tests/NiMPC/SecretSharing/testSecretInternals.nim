import unittest
import asynctest
import parties
import NiMPC/Parties
import NiMPC/Math
import NiMPC/SecretSharing
import NiMPC/SecretSharing/Internals

suite "secret sharing internals":

  asynctest "opens a secret without losing precision":
    let large = high(uint32)
    let secret = Party().rawShare(large)
    let product = await (secret * 1000'u32).openRawShare()
    check product == 1000'u64 * uint64(large)

