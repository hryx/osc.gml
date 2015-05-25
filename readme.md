# osc.gml

A simple [OpenSoundControl](http://opensoundcontrol.org/) (OSC) client and
server for Game Maker.

Use these scripts if you would like to send or receive OSC messages in a
Game Maker project.

## Requirements

Game Maker: Studio version 1.4.1514 or higher (`network_send_udp_raw()`
did not exist before this version)

## How do?

### Init

Before sending or receiving, you must init the system from a handler object:

```
osc_init(send_url, send_port, receive_port);
```

### Send

Send a message with `osc_send()`. The resource pattern is mandatory. To send
other message arguments, prefix them with a string of typetags as specified in
the [OSC 1.0 specification](http://opensoundcontrol.org/spec-1_0).

- `i`: int32 (signed)
- `f`: float32
- `s`: OSC-string

Here's an example:

```
osc_send("/server/some/pattern", "fsi", 2.71828, "I hate Game Maker", 64);
```

### Receive

In the "Networking Event" of your handler object, receive messages with
`osc_receive()`, which returns an array containing the OSC pattern and possibly
message arguments. If an error occurrs, `false` is returned.

```
var messages = osc_receive();
for (i = 0; i < array_length_1d(messages); i++) {
    show_messages(string(messages[i]));
}
```

This library only cares about messages sent to the socket created with
`osc_init()`, so make sure you are receiving messages on the correct port.

### Caveats

Remeber that Windows may bitch at you if you have a firewall turned on.

## Limitations

- Supported OSC data types are limited to: string, float, int.
- Currently, bundles (OSC messages begining with `#bundle`) are not supported.

## Liscense

Public Domain

Buuuuuut: feedback, issues, pull requests, and attribution are all greatly
appreciated.
