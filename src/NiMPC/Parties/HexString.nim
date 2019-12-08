import sequtils
import strutils
import monocypher

proc hex*(bytes: Key | Nonce | Mac | seq[byte]): string =
  cast[string](bytes.toSeq()).toHex()

