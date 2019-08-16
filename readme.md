NiMPC
=====

A Secure Multi-party Computation (MPC) library for [Nim](https://nim-lang.org).
Allows you to do joint computations with multiple parties while each party keeps
their inputs private. We're working towards an implementation of the
[SPDZ2k](https://eprint.iacr.org/2018/482.pdf) protocol.

This is very much a work in progress. At least the following still needs to be
implemented before it can be considered feature complete:

- [ ] A networking layer, to run multiple parties on separate machines.
- [ ] Support for more mathematical operations, such as division and square
      root.
- [ ] MAC checking, to make computations safe against active adversaries.
- [ ] OT extensions, to make multiplications faster and to circumvent a known
      flaw in the Oblivious Transfer protocol (see section 1.1. of the
      [OT paper](https://eprint.iacr.org/2015/267.pdf)).
