import sysrandom

{.rangeChecks: off.}

proc random*[T: SomeInteger | array](): T =
  getRandomBytes(addr result, sizeof(result))
