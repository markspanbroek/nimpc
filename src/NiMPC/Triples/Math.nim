proc `*`*[T](a: bool, b: T): T =
  if a:
    result = b
  else:
    result = 0

proc `*`*[T](a: openArray[bool], b: T): seq[T] =
  for element in a:
    result &= element * b

proc `+`*[T](a: openArray[T], b: openArray[T]): seq[T] =
  assert a.len == b.len
  for i in 0..<a.len:
    result &= a[i] + b[i]

proc `-`*[T](a: openArray[T]): seq[T] =
  for element in a:
    result &= T(0) - element
