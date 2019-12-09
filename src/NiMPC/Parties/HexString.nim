import sequtils
import strutils

proc hex*(bytes: openArray[byte]): string =
  cast[string](bytes.toSeq()).toHex()

proc parseHexSeq*(s: string): seq[byte] =
  cast[seq[byte]](parseHexStr(s))

proc parseHexArray*(s: string, length: static int): array[length, byte] =
  let sequence = parseHexSeq(s)
  assert sequence.len == length
  copyMem(unsafeAddr result[0], unsafeAddr sequence[0], length)
