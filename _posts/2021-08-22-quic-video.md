---
layout: post
title: "MoQ: Drafts, use cases, and requirements"
date: 2021-08-22
tags: quic
---

This is a look at the published drafts exploring media protocols over QUIC,
briefly comparing them, identifying use cases that would fit under such a
protocol and some of the requirements that would apply.

# Summary of existing draft documents

## [draft-rtpfolks-quic-rtp-over-quic-01](https://datatracker.ietf.org/doc/html/draft-rtpfolks-quic-rtp-over-quic-01)

Published back in 2017, this document doesn't define a protocol itself, but
describes the use cases and considerations in doing so. It also explores
specific design decisions in relation to quick, such as mapping of RTP concepts
into QUIC.

## [draft-hurst-quic-rtp-tunnelling-01](https://datatracker.ietf.org/doc/html/draft-hurst-quic-rtp-tunnelling-01)

QRT encapsulates RTP and RTCP and define the means of using QUIC datagrams
with them, defining a new payload within a datagram frame which distinguishes
packets for a RTP packet flow vs RTCP. 

## [draft-engelbart-rtp-over-quic-00](https://datatracker.ietf.org/doc/html/draft-engelbart-rtp-over-quic-00)

This specification also encapsulates RTP and RTCP but unlike QRT which simply
relies on the default QUIC congestion control mechanisms, it defines a set of
requirements around QUIC implementation's congestion controller to permit the
use of separate control algorithms.

## [draft-kpugin-rush-00](https://datatracker.ietf.org/doc/html/draft-kpugin-rush-00)

RUSH uses its own frame types on top of QUIC as it pre-dates the datagram
specification; in addition individual media frames are given their own stream
identifiers to remove HoL blocking from processing out-of-order. 

It defines its own registry for signalling codec information with room for
future expansion but presently is limited to a subset of popular video and audio
codecs and doesn't include other types (such as subtitles, transcriptions, or
other signalling information) out of bitstream.

## [draft-sharabayko-srt-over-quic-00](https://haivision.github.io/srt-rfc/draft-sharabayko-srt-over-quic.html)

[SRT](https://datatracker.ietf.org/doc/draft-sharabayko-srt/) itself is a
general purpose transport protocol (built on top of the
[UDT](https://udt.sourceforge.io) protocol) primarily for contribution transport
use cases and this specification covers the encapsulation and delivery of SRT on
top of QUIC using datagram frame types.  This specification sets some
requirements regarding how the two interact and leaves considerations for
congestion control and pacing to prevent conflict between the two protocols.

# Key points of contrast and comparison

* Both QRT and the Engelbart draft attempt to use existing payloads of RTP,
  RTCP, and SDP unlike RUSH and SRT, as well as using existing Datagram frames
* RUSH introduces new frame types as its development pre-dates Datagram frames
* Both QRT and RUSH specify ALPN identification; the Engelbart and SRT drafts do not.
* All drafts take differing approaches to flow/stream identification and
  management; some address congestion control and others just omit the subject
  and leave it to QUIC to handle

# Defining the use-cases

[Section 2 of draft-rtpfolks-quic-rtp-over-quic](https://datatracker.ietf.org/doc/html/draft-rtpfolks-quic-rtp-over-quic-01#section-2)
does a comprehensive job covering end-user applications (such as peer-to-peer
video call uses) but in addition there should also be attention made to the
additional cases:

1. **Unidirectional live stream contribution** - two immediate scenarios that
best describe this is firstly users on a streaming platform in a remote scenario
from their phone live streaming an event or going on to an audience in real time
in relatively low bitrates (~1-5Mbit). The second scenario is larger bitrate
contribution feeds in broadcast. This can be an OB feed "back to base" into
playout gallery, or from playout facilities to online distribution platforms.
Today there's a multitude of existing protocols used for this, including but not
limited to SMPTE 2022-6/7, RIST, SRT, ZiXi, etc.

2. **Distribution from platform to audience**. This is called out in part with
the above draft (#3) but the use of WebRTC or RTSP today for On-Demand is not
typical with adaptive streaming like HLS and DASH being predominantly used as
WebRTC is more applicable in latency sensitive contexts. Instead use cases where
there is live streaming of TV linear output, or live streaming such as Twitch or
Facebook, or non-UGC services like OTT offerings made by broadcasters.

# What should a Media over QUIC protocol have?

Perhaps the most important requirements that should be settled first are those
with respect to transport - re-transmission, packet loss, congestion control, and
recovery mechanisms. The current design of QUIC sets some boundaries regarding
these points and if changes are required it may result in extensions or possibly
changes to the underlying protocol. In particular congestion control and the
signalling of it needs considerable attention, either extending QUIC to disable it
and leave it to the underlying protocol to manage or for implementations to have
greater controls available to the congestion control state machine.

Multicast support should be considered out of scope for the protocol initially, and although
there has been some work already in this space with
[draft-pardue-quic-http-mcast](https://datatracker.ietf.org/doc/draft-pardue-quic-http-mcast/)
this might be considered in later versions should QUIC gain the capabilities to
do so.

Additionally I believe a key requirement that needs to be met is codec agility,
ideally using existing mechanisms to transmit and negotiate codecs in use.
Encapsulation of the media bitstream should be kept as lightweight, simple, and
based on existing standards as much as possible. Additionally, mid-session
changes should also be a requirement allowing for the encoder/decoder to adjust
the media bitrate and other parameters due to changes in the networking
conditions or other factors, or even dropping streams entirely such as falling
back to audio-only.

Bi-directionality of flows should be considered; this is not exclusively for 
support video-conferencing capability in one/many scenarios, but also for broadcast
use cases (such as needing an
[IFB](https://en.wikipedia.org/wiki/Interruptible_foldback) in OB situations)
where it's closer to one to one, usually with an audio only-channel on the
return path.

Integration with
[WebTransport](https://datatracker.ietf.org/doc/html/draft-ietf-webtrans-http3-01)
should also be considered - in particular the behaviours around negotiation of
HTTP/3 Datagrams during connection establishment. It may also arise that
implementers of WebTransport are not interested as WebRTC (and WISH) may fulfil
their requirements.

Authentication should also be part of the specification. It's likely that
implementers will not find using TLS mutual authentication appropriate and that
the protocol will need some means of having clients be able to authenticate with
a set of provided credentials to prevent [Max
Headroom](https://en.wikipedia.org/wiki/Max_Headroom_signal_hijacking) making an
online debut. This should be kept simple, as it's likely implementers will have
tie-in with authentication separately, for example the mobile use-case above
would have the app able to use the user credentials as means of obtaining a key.

# How should the IETF proceed?
I think the next step is BoF formation, with the aim of defining consensus over
the use cases and requirements, and a charter that describes the work including
clarity about how a WG will engage with potential changes to QUIC but also any
changes that would need wider discussion (for example with avtcore).

