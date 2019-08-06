import unittest
import sequtils
import math
import NiMPC/Random

test "generates random values of different types":
  check random[int]() != random[int]()
  check random[uint64]() != random[uint64]()
  check random[array[10, uint8]]() != random[array[10, uint8]]()

test "generates a uniform distribution":
  let numbers = random[array[1000, int8]]()
  let average = numbers.mapIt(float(it) / 1000).sum()
  check abs(average) < 10
