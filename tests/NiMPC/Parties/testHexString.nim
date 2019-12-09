import unittest
import NiMPC/Parties/HexString

suite "hex strings":

  test "convert array to hex string":
    check hex([0xab'u8, 0xcd'u8, 0xef'u8]) == "ABCDEF"

  test "convert hex string to byte sequence":
    check parseHexSeq("ABCDEF") == @[0xab'u8, 0xcd'u8, 0xef'u8]

  test "conversion to sequence fails when hex string is incorrect":
    expect ValueError:
      discard parseHexSeq("wrong!")

  test "convert hex string to byte array":
    let a: array[3, byte] = parseHexArray("ABCDEF", 3)
    check a == [0xab'u8, 0xcd'u8, 0xef'u8]

  test "conversion to array fails when hex string is incorrect":
    expect ValueError:
      let _: array[3, byte] = parseHexArray("wrong!", 3)

  test "conversion to array fails when array length is incorrect":
    expect Exception:
      let _: array[2, byte] = parseHexArray("ABCDEF", 2)
