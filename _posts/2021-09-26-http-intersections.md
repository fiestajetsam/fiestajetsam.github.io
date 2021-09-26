---
layout: post
title: "Intersections in HTTP standardisation"
date: 2021-09-26
---

Protocols are built on top of one another, and consequentially sometimes you
have to transmit information about one protocol over another one in the "stack"
(or layer). Besides DNS, which is slightly orthoganol to this, when we look at
HTTP what kind of standardisation which drafts are passing information to and
from which protocols, and why?

To answer this, about a year ago I pulled every draft I could find and mapped it
out. Whilst we describe protocols like HTTP and TLS to only be "client/server",
in reality many of these specifications are when a proxy or load balancer are
involved and one connection for one protocol stops and another separate session
begins. What the diagram below shows is for each protocol which protocol
conveys information to which other besides its own.

![Diagram showing intersections between draft documnents](/media/2021-09-26-http-intersections/intersections_diagram.svg)
<sub>[Original Image &#x2934;](/media/2021-09-26-http-intersections/intersections_diagram.svg)</sub>

From this visualisation there are several patterns that emerge - firstly the
need for proxy servers to tell clients information about their connectivity to
origin but from the proxy server's perspective and not so much from the origin's
perspective. This information about TLS and TCP/UDP connectivity gets bubbled up
into the client's HTTP response with use case covering diagnostic purposes, but
with somtimes implications for an application on the client to change behaviour,
say falling back to a different host or throttling requests but these are not
intrinsic to the specifications.

Secondly is the use cases around TLS certificate presentation and negotiation,
using HTTP as a means to present additional certificates and negotiation
post-handshake, leading to complications that more tightly couple the state of a
TLS connection to the HTTP server. In some use cases this may ultimately be a
good thing, optimising existing connections and not forcing a complete restart
of the TCP or TLS session at the cost of this coupling and the complexity
associated with it.

## Implications

Because clients are more likely than not to be web browsers, privacy and
security with regards to information leakage will continue to remain a concern.
Part the reason we decided to not move forward with
[draft-ohanlon-transport-info-header
](https://datatracker.ietf.org/doc/draft-ohanlon-transport-info-header/) at the
end of the day is that many raised issues of exposing such low level connection
information as it could be used for user fingerprinting if mishandled even if it
has value in exposing that data to inform video streaming use cases, where
congestion detection may change the player to change behaviour.

I haven't covered QUIC here, which may see some possible new patterns where a
load balancer or proxy could transmit origin information such as timestamps or
spin bit to help inform end-to-end latency measure and not just client to it's
next hop. All of that could remain at the transport layer and not have to be
encapsulated into HTTP/3, simplifying things.

## Considerations

HTTP 1.1 and 2 are not going away any time soon and even in a potential future
where QUIC and HTTP 3 make up a majority stake of HTTP traffic we'll continue to
see the former being used to serve from origin servers. Although we largely
define these protocols in simplistic client and server models, in reality they
always have multiple, variable tiers of interactions for proxies, load balancers
and the likes, and information exchange of session data should factor in those
patterns - [RFC 8586](https://datatracker.ietf.org/doc/html/rfc8586) is one such example.

Finally I think that the quic, tls, and httpbis working groups should continue to be
mindful of the way in which information and control data is used between the
protocols to prevent the proverbial tail wagging the dog.

