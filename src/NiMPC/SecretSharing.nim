import bigints
import asyncdispatch
import sequtils
import sysrandom
import BigIntegers
import Communication

type Secret* = object
  share*: BigInt

proc random*: Secret =
  result = Secret(share: getRandom())

method reveal*(party: Party, secret: Secret, recipient: Party) {.async,base.} =
  await party.send(recipient, secret.share)

method open*(party: Party, secret: Secret): Future[BigInt] {.async,base.} =
  var shares = @[secret.share]
  for sender in party.peers:
    shares.add(await party.receive(sender))
  result = shares.foldl(a + b)

method share*(party: Party, private: BigInt): Future[Secret] {.async,base.} =
  let r = random()
  let openR = await party.open(r)
  result = Secret(share: r.share - openR + private)

method obtain*(party: Party, sender: Party): Future[Secret] {.async,base.} =
  result = random()
  await party.reveal(result, sender)
