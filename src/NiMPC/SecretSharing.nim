import bigints
import asyncdispatch
import sequtils
import sysrandom
import BigIntegers
import Communication

type Secret* = object
  myShare: BigInt

proc random*: Secret =
  result = Secret(myShare: getRandom())

method reveal*(party: Party, secret: Secret, recipient: Party) {.async,base.} =
  await party.send(recipient, secret.myShare)

method obtain*(party: Party, secret: Secret): Future[BigInt] {.async,base.} =
  var shares = @[secret.myShare]
  for sender in party.peers:
    shares.add(await party.receive(sender))
  result = shares.foldl(a + b)
