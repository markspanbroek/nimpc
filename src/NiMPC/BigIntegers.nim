import bigints

converter toBigInt*(value: int): BigInt =
  result = value.initBigInt
