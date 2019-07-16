import bigints

converter toBigInt*(value: int): BigInt =
  result = value.initBigInt

converter toBigInt*(value: uint32): BigInt =
  result = value.initBigInt
