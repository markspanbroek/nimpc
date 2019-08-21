NiMPC
=====

A secure multi-party computation (MPC) library for the [Nim][nim] programming
language. Allows you to do joint computations with multiple parties while each
party keeps their inputs private. We're working towards an implementation of the
[SPDZ2k][spdz2k] protocol.

Work in Progress
----------------

This is very much a work in progress. At least the following still needs to be
implemented before it can be considered feature complete:

- [ ] A networking layer, to run multiple parties on separate machines.
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

    requires "NiMPC >= 0.1.0 & < 0.2.0"

Example
-------

Import these modules:
```nim
import NiMPC
import asyncdispatch
```

Connect two parties that will jointly perform a computation. Because we have not
implemented a networking layer yet, both parties will run on the same machine.
```nim
let party1, party2 = Party()
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
