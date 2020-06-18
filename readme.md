NiMPC
=====

A secure multi-party computation (MPC) library for the [Nim][nim] programming
language. Allows you to do joint computations with multiple parties while each
party keeps their inputs private. We're working towards an implementation of the
[SPDZ2k][spdz2k] protocol.


![CI Status](https://github.com/markspanbroek/nimpc/workflows/CI/badge.svg)

Work in Progress
----------------

This is very much a work in progress. At least the following still needs to be
implemented before it can be considered feature complete:

- [x] A networking layer, to run multiple parties on separate machines.
- [ ] Support for more mathematical operations, such as division and square
      root.
- [ ] MAC checking, to make computations safe against active adversaries.
- [ ] OT extensions, to make multiplications faster and to circumvent a known
      flaw in the Oblivious Transfer protocol (see section 1.1. of the
      [OT paper](https://eprint.iacr.org/2015/267.pdf)).

Installation
------------

Ensure that you have a [recent version of Nim installed][nim-install].

Use the [Nimble][nimble] package manager to add NiMPC to an existing project.
Add the following to its .nimble file:

    requires "NiMPC >= 0.4.0 & < 0.5.0"

Examples
--------

### Local Computation

Perform a computation with two parties. For now, both parties will run on the
same machine, we'll cover how to connect parties over a network later.

Import these modules:
```nim
import NiMPC
import asyncdispatch
```

Create two parties that will jointly perform a computation.
```nim
let party1, party2 = newLocalParty()
```

Calling destroy when the local parties are no longer in scope ensures that their
secret keys are securely wiped from memory.
```nim
defer: destroy(party1, party2)
```

Connect the parties.
```nim
connect(party1, party2)
```

Specify the computation that the first party will perform. We'll use the `async`
and `await` macro's from  the [asyncdispatch][asyncdispatch] module.
```nim
proc computation1 {.async.} =
```
The first party shares a secret input with the other party. Currently only 32
bit unsigned numbers (uint32) are supported.
```nim
  let input1: Secret = party1.share(21)
```

Obtain a share of the secret input from the second party. The obtained secret
does not reveal anything about the number that was input by the other party.
```nim
  let input2: Secret = party1.obtain(party2)
```

The two inputs are multiplied. Addition and subtraction are also
supported.
```nim
  let product: Secret = input1 * input2
```

The product is revealed. This allows both parties to learn the product of the
two secret inputs.
```nim
  let revealed: uint32 = await product.reveal() # equals 42
```

Specify the equivalent computation for the second party:
```nim
proc computation2 {.async.} =
  let input1: Secret = party2.obtain(party1)
  let input2: Secret = party2.share(2)
  let product: Secret = input1 * input2
  let revealed: uint32 = await product.reveal() # equals 42
```

Run the multi-party computation:
```nim
waitFor all(computation1(), computation2())
```

### Networking

Perform a computation with two parties over a network connection. Just like the
previous example we start with two parties, but we do not connect them just yet.

```nim
import NiMPC
import asyncdispatch

let party1, party2 = newLocalParty()
defer: destroy(party1, party2)
```

These parties will listen on different ports on localhost.

```nim
const host = "localhost"
const port1 = Port(23455)
const port2 = Port(23456)
```

Specify the computation that the first party will perform.
```nim
proc computation1 {.async.} =
```

Start listening for incoming messages on the correct port.
```nim
  let listener = party1.listen(host, port1)
```

Ensure that we stop listening when the listener is no longer in scope:
```nim
  defer: await listener.stop()
```

Connect to the second party. This returns a proxy for the Party that is running
on the other side of the connection.
```nim
  let proxy2 = await party1.connect(party2.id, host, port2)
```

Ensure that we close the connection when the proxy is no longer in scope.
```nim
  defer: proxy2.disconnect()
```

Use the local party and the proxy for the remote party to perform the
computation.

```nim
  let input1 = party1.share(21)
  let input2 = party1.obtain(proxy2)
  let product = input1 * input2
  let revealed = await product.reveal() # equals 42
```

Specify the equivalent computation for the second party:
```nim
proc computation2 {.async.} =
  let listener = party2.listen(host, port2)
  defer: await listener.stop()

  let proxy1 = await party2.connect(party1.id, host, port1)
  defer: proxy1.disconnect()

  let input1 = party2.obtain(proxy1)
  let input2 = party2.share(2)
  let product= input1 * input2
  let revealed = await product.reveal() # equals 42
```

Run the multi-party computation:
```nim
waitFor all(computation1(), computation2())
```

Thanks
------

NiMPC is inspired by the great work done by the [FRESCO][fresco] and
[MPyC][mpyc] developers. It would also not have existed without the research
that went into the [SPDZ2k][spdz2k] protocol.

[nim]: https://nim-lang.org
[nim-install]: https://nim-lang.org/install.html
[nimble]: https://github.com/nim-lang/nimble
[asyncdispatch]: https://nim-lang.org/docs/asyncdispatch.html
[fresco]: https://github.com/aicis/fresco
[mpyc]: https://github.com/lschoe/mpyc
[spdz2k]: https://eprint.iacr.org/2018/482.pdf
