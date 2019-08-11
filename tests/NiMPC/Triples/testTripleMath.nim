import unittest
import NiMPC/Parties
import NiMPC/Triples/Math
import NiMPC/SecretSharing/Internals

suite "math for triple generation":
  
  test "multiplies with a boolean":
    check true * 42 == 42
    check false * 42 == 0

  test "multiplies sequence of booleans with a constant":
    check @[true, false] * 42 == @[42, 0]

  test "adds sequences of shares":
    let a = @[Share(1), Share(2), Share(3)]
    let b = @[Share(10), Share(20), Share(30)]
    check a + b == @[Share(11), Share(22), Share(33)]

  test "refuses to add sequences of different length":
    expect Exception:
      discard @[Share(1)] + @[Share(2), Share(3)]

  test "negates sequence of shares":
    let a = @[Share(1), Share(2), Share(3)]
    check -a == @[Share(-1), Share(-2), Share(-3)]

  test "computes share * secret without losing precision":
    let largeUint64 = 0'u64-2'u64
    let a = Share(largeUint64 div 2)
    let b = Secret(party: Party(), share: Share(2))
    check (a * b).share == Share(largeUint64)

  test "computes secret + share without losing precision":
    let largeUint64 = 0'u64-2'u64
    let a = Secret(party: Party(), share: Share(largeUint64 div 2))
    let b = Share(largeUint64 div 2)
    check (a + b).share == Share(largeUint64)
