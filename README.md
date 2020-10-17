# Enphase Envoy

## Overview

This is a simple Control4 driver to pull data from the Enphase Envoy.

The driver automatically detects the Envoy using mDNS, so no
configuration of the IP address is necessary.

## Configuration

**Poll Interval** The driver will periodically query the Envoy to get
its status. This sets how often, in seconds, to poll the Envoy.

## Grid Detection

If you have an Enpower, you can add a Contact Switch sensor driver and
connect it to the Grid Status contact sensor of the Envoy driver.

## Driver Events

The driver will poll the Envoy for its current status. If it fails,
the driver will send an `Offline` event. When it comes back online, it
will send a `Discovered` event.

Please note that the local Envoy web server can be quite slow, so you
may get spurious `Offline` events. One mitigation strategy is to use a
Timer. For example, when you receive an `Offline` event, start a Timer
for 2 minutes. If you get a `Discovered` event, cancel the timer. If
the timer expires, then you can be reasonably certain that the Envoy
is offline.

## Change Log

Version 7:

- Initial release
