/* OSC event callback.
 * Parses incoming OSC packets and returns an array: Address pattern and args.
 * An integer (false or a negative number) is returned upon error.
 * Each OSC message will be a list containing an address pattern and
 * optionally argument values. Values are translated to native GML types:
 * string, real (blob not supported).
 * Currently, #bundle messages are not supported.
 * This script must be called in an object's Networking Event through the GUI.
 */

// Information from the Networking event
var server = async_load[? "id"];
var type = async_load[? "type"];
var buf = async_load[? "buffer"];
var size = async_load[? "size"];

// Only interested in payloads on the server socket
if (server != osc_listen_socket) {
    return -1;
}
if (type != network_type_data) {
    return -1;
}

// Local shit
var i;
var j;
var addrpattern;
var typetagstr;
var typetags;
var arguments;
var buf_tmp = buffer_create(4, buffer_fixed, 4);
var messages;

//// Parse the packet ////

// Address pattern
buffer_seek(buf, buffer_seek_start, 0);
addrpattern = buffer_read(buf, buffer_string);
if (string_length(addrpattern) < 1) {
    return false;
}

// Type tags
while (buffer_tell(buf) % 4 != 0) {
    buffer_seek(buf, buffer_seek_relative, 1);
}
typetagstr = buffer_read(buf, buffer_string);
if (string_char_at(typetagstr, 1) != ",") {
    return false;
}
i = 1;
while (true) {
    i++;
    var ch = string_char_at(typetagstr, i);
    if (ch == "") {
        break;
    }
    switch (ch) {
        case "i":
        case "f":
        case "s":
            typetags[i - 2] = ch;
            break;
        default:
            return false;
    }
}

// Arguments
while (buffer_tell(buf) % 4 != 0) {
    buffer_seek(buf, buffer_seek_relative, 1);
}
for (i = 0; i < array_length_1d(typetags); i++) {
    // Don't go past the end of the buffer
    var pos = buffer_tell(buf);
    if (pos >= size) {
        return false;
    }
    // Grab next argument
    tag = typetags[i];
    switch (tag) {
        case "s":
            arguments[i] = buffer_read(buf, buffer_string);
            break;
        case "i":
        case "f":
            // We must swap to big-endian for OSC
            buffer_seek(buf_tmp, buffer_seek_start, 0);
            var k = 0;
            var j = 3;
            for (j = 3; j >= 0; j -= 1) {
                var byte = buffer_peek(buf, pos + j, buffer_u8);
                buffer_poke(buf_tmp, k, buffer_u8, byte);
                k++;
            }
            if (tag == "i") {
                arguments[i] = buffer_read(buf_tmp, buffer_s32);
            }
            else if (tag == "f") {
                arguments[i] = buffer_read(buf_tmp, buffer_f32);
            }
            buffer_seek(buf, buffer_seek_relative, 4);
            break;
        default:
            return false; // Unreachable
    }
    // Seek to end of 4-bytes padding
    while (buffer_tell(buf) % 4 != 0) {
        buffer_seek(buf, buffer_seek_relative, 1);
    }
}

// That's it
messages[0] = addrpattern;
for (i = 0; i < array_length_1d(arguments); i++) {
    messages[i + 1] = arguments[i];
}

return messages;
