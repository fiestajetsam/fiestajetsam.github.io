---
layout: post
title: "Time representations in HTTP"
date: 2022-02-20
---

This post is a collection of my thoughts around how we represent time values in
HTTP, and HTTP based protocols, making some room for doing better in the future.
All of this started after noticing the call for adoption for
[draft-nottingham-http-structure-retrofit](https://datatracker.ietf.org/doc/draft-nottingham-http-structure-retrofit/)
and the approach it at time of writing is taking.

# Current state of things
HTTP itself represents time in a few headers with `Date`, `Expires`, and
`Last-Modified` being most notable. This value whose ABNF is defined in [RFC
5322](https://datatracker.ietf.org/doc/html/rfc5322#section-3.3) is very human
readable, features a redundant day of week field and is more expensive than
other formats to parse.  For example, it looks something like this:

```
Date: Tue, 15 Feb 2022 22:52:34 GMT
```

Newer standards have moved away from using this format, for example
[JWT](https://datatracker.ietf.org/doc/html/rfc7519) has opted for POSIX
timestamps. These come across as quite convenient as they can be represented
with a (hopefully 64 bit) integer to future-proof against 2038 roll-over, most
programming languages can convert them into a object or string that represents
something code or a human could manipulate or output, and the epoch is known -
in fact, a huge assumption people make is that there is more than just one
epoch, and this is not the first.

There's a few other issues with this approach - firstly, POSIX time is not the
same as UTC, as when we get into the nitty-gritty detail, the two diverge when it
comes to leap seconds, something that is best explained by [RFC
7164](https://datatracker.ietf.org/doc/html/rfc7164#section-3.4). This could
lead to a few scenarios:
* Either client or server don't know the actual time due to outdated leap second
  data. In most systems this is usually provided by tzdb, and updates provided
  by OEMs or distributions but of course these can fall behind.
* Changes in request behaviours because of this mismatch, which could see
  repeated requests or unexpected behaviours in cache usage.

# Alternatives Approaches
What is needed is fairly minimal; a UTC representation, at least second level
resolution, in the least number of bytes on wire and computationally both cheap
to parse and generate. As a bonus, a format that is human readable - but this
isn't hard and fast. One of HTTP's original gains is it being text-based, but it
appears this is no longer a priority in favour of having tooling help the humans
with readability. Regardless compatibility in representation between the
protocol versions is required.

## RFC 3339
One option is using [RFC 3339](https://datatracker.ietf.org/doc/html/rfc3339),
which is a subset of [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601). This is
more easily machine parsable, represents UTC time (and Gregorian date) and can
be human readable. Bytes on the wire are reduced by approximately a third, but
the compute expense remains largely similar to the incumbent.

```
New-Date: 2022-02-15T22:52:34Z
```

## An alternate integer
A different approach could be either selecting a different counting of time
which explicitly includes leap seconds, or even transmits them separately. In
the latter case, we've only seen two dozen or so additional leap seconds in the
past five decades so a proposal _could_ transmit it as an unsigned 8-bit
integer. UNIX epoch (January 1st, 1970) is a convenient epoch but [far from the
only
one](https://en.wikipedia.org/wiki/Epoch_(computing)#Notable_epoch_dates_in_computing),
and another closer to the present day could be chosen to prolong the next
roll-over, or an additional "era" field integer like the one specified in [RFC
5905](https://datatracker.ietf.org/doc/html/rfc5905#section-6) could address
this. All of this comes with an explicit cost of complexity to implementors, who
will have to do the math and calculate this value (and potentially introduce
bugs) instead of using a API provided by their language tooling.

# ... or just accept the leap? 
This is another outcome, just expanding the use of POSIX time further and have
them deal with leap second conversions and any errors that may occur. If there's
anything that MUST be provided in doing so is the specifications being explicit
about the need for conversion and leap second information for any implementation.
