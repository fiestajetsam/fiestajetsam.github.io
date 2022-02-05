---
layout: post
title: "Future time protocol security"
date: 2022-02-04
---

Over the past year whilst I have been [authoring a
draft](https://datatracker.ietf.org/doc/draft-gruessing-ntp-ntpv5-requirements/)
that sets out the requirements for the next version of the NTP protocol, the
response I've had from both the working group and from wider industry when
discussing the subject have lead me to think more in depth about both the
existing landscape as well as what we'll need in future and why.

## A brief introduction to the existing time protocols

There's only a few protocols in play that continue to be developed, used, and be
recommended for deployment in new systems.
[Roughtime](https://datatracker.ietf.org/doc/draft-ietf-ntp-roughtime/)
continues to stands place more to solve the "bootstrap" problem of a device
needing just enough time information with just enough precision so things like
PKI can work so time validation on X.509 certificates can occur. NTPv4 being
much older has had to "bolt-on" security with NTS, something that may change
with NTPv5, but may also be reserved for either future extension or versions.

For new protocols that operate on public internet, regardless of their purpose
the default position is (at least by wider IETF participants and interested
groups) that protocols have authentication and confidentiality by default, and
can only be opted out of only with exception - i.e. you have to be able to
demonstrate why they can't be part of the protocol. If a protocol like OCSP was
designed today from scratch, it would likely pass this test but not without
challenge.

# What about the future?

The two significant pieces of the puzzle that will advance us towards having
stronger time based attestation and verification that I can think of cover
passing on information, and bringing this closer in-band.

## Cascading of Authentication Information

Many deployments requiring both synchronisation and time information start with
a GNSS (or multiple) as a starting point to obtain UTC or TAI, which is
then used to train a local oscillator and propagate services in the IP space.
These currently are completely decoupled from an authentication standpoint, and
the status of the GNSS receiver verifying the messages is not something
supported. Having the means for a device operating as both GNSS receiver and
source of IP time services be able to describe via the time protocols the status
of its receiver, if any authentication has failed or any other errors would
allow for more resilient designs where clients can fail over, or further carry
some attestation that its upstream source was likely not being spoofed
which may be beneficial.

The solution here critically must remain agile to the GNSS platforms, both as
more of them may support this in future but also changes in their choices of
cryptographic primitives or functionality.

## Beyond NTS and further in-band authentication

[NTS](https://datatracker.ietf.org/doc/html/rfc8915) is largely a bolt-on to
NTPv4, and whilst it's a vast improvement to autokey is still adjacent to the
core timing protocol itself. This comes with the advantage of separating out
some of the crypto complexity that may hamper synchronisation, but adds
complexity for implementers having to effectively implement and align two
separate protocols. In the future this could all be part of the one protocol,
where key exchange is part of the handshake, or just simply broadcast out.

This has numerous challenges to overcome, most notably for hardware timestamping
which would require hardware to be able to generate authentication messages in
very low, constant time and do so with very minimal overhead. Combining this
with demands for codec agility may complicate hardware further. Further the
issue of unicast vs multicast has to be addressed; whilst concepts like
[TESLA](https://datatracker.ietf.org/doc/html/rfc4082) could work in multicast
deployments, for NTP deployments by numbers the vast majority are unicast where
it's not really feasible. New means to distribute efficiently handle
authentication for thousands or tens of thousands of nodes with minimal overhead
should be looked at.

The bootstrapping of authentication would still continue to be something that
needs to happen out of band - this can happen via similar methods to how TLS
operates today.

# How do we get to this future?

This is the difficult question, and requires not only piecing together existing
capabilities but doing standardisation cat herding as well - and if the
industries don't think it's worth it, some of these may not be realised. My hope
is that NTPv5 will have set in stone requirements for both authentication of
time information, and extension capabilities that allow space for these kinds
abilities in the protocol to be developed. Further, I hope that the interfaces
both GNSS providers as well as receiver makers expose the key pieces of data
that allow this carry through systems into IP.

Only time will tell.
