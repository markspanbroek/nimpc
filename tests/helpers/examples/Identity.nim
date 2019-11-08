import NiMPC/Parties/Identity
import sysrandom
import monocypher

proc exampleIdentity*: Identity =
  initIdentity(getRandomBytes(sizeof(Key)))
