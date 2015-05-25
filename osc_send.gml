/* Send a message to the OSC server.
 * osc_init() must have been called already or this will fail.
 * Pattern argument is required and errs if missing.
 * Function returns if optional parameters are malformed.
 * Because GML does not distinguish floats from ints,
 * one must specify the type tag manually.
 * Usage:
 *   osc_send("/pattern/to/send", "fsi", 2.3, "what", 16);
 *   osc_send("/pattern/no/args");
 */

// Local shit
var i;
var j;
var addrpattern;
var oscargs = 0;
var nargs = 0;
var typetag;
var buf_tmp = buffer_create(4, buffer_fixed, 4);

// Validate
if (argument_count < 1) {
    show_error("osc_send(): Not enough arguments.", true);
}
else if (is_undefined(osc_is_setup)) {
    show_error("osc_send(): OSC not initialized.", true);
}

// Address pattern
addrpattern = argument[0];
if (!is_string(addrpattern)) {
    show_debug_message("osc_send(): Expected address pattern (string).");
    return false;
}

// Type tag and arguments
if (argument_count > 1) {
    typetag = argument[1];
}
else {
    typetag = "";
}

// Fill argument type array based on type-tag
for (i = 0; i < string_length(typetag); i += 1;) {
    if (i >= argument_count - 2) { // if we exceed number of actual arguments
        break;
    }
    var arg = argument[i + 2];
    switch(string_char_at(typetag, i + 1)) { // string_char_at starts from 1
        case "s":
            if (!is_string(arg)) {
                return false;
            }
            oscargs[i] = arg;
            break;
        case "i":
            if (!is_real(arg)) {
                return false;
            }
            oscargs[i] = floor(arg);
            break;
        case "f":
            if (!is_real(arg)) {
                return false;
            }
            oscargs[i] = arg;
            break;
        default:
            return false;
    }
}
typetag = string_insert(",", typetag, 1); // OSC type-tag starts with a comma
if (is_array(oscargs)) {
    nargs = array_length_1d(oscargs);
}

// All OK; clear the the buffer and prepare to write message
buffer_seek(osc_send_buf, buffer_seek_start, 0);
buffer_fill(osc_send_buf, 0, buffer_u8, $0, buffer_get_size(osc_send_buf));
buffer_seek(osc_send_buf, buffer_seek_start, 0);

// Address pattern
buffer_write(osc_send_buf, buffer_string, addrpattern);
while (buffer_tell(osc_send_buf) % 4 != 0) { // pad to next 4th byte
    buffer_write(osc_send_buf, buffer_u8, $0);
}

// Type-tag
buffer_write(osc_send_buf, buffer_string, typetag);
while (buffer_tell(osc_send_buf) % 4 != 0) { // pad to next 4th byte
    buffer_write(osc_send_buf, buffer_u8, $0);
}

// OSC arguments
for (i = 0; i < nargs; i += 1;) {
    var char = string_char_at(typetag, i + 2); // index from 1; skip comma
    switch (char) {
    case "s":
        buffer_write(osc_send_buf, buffer_string, oscargs[i]);
        while (buffer_tell(osc_send_buf) % 4 != 0) { // pad to next 4th byte
            buffer_write(osc_send_buf, buffer_u8, $0);
        }
        break;
    case "i":
    case "f":
        // We must swap to big-endian for OSC
        buffer_seek(buf_tmp, buffer_seek_start, 0);
        if (char == "i") {
            buffer_write(buf_tmp, buffer_s32, oscargs[i]);
        }
        else if (char == "f") {
            buffer_write(buf_tmp, buffer_f32, oscargs[i]);
        }
        buffer_write(buf_tmp, buffer_s32, oscargs[i]);
        for (j = 3; j >= 0; j -= 1) {
            var byte = buffer_peek(buf_tmp, j, buffer_u8);
            buffer_write(osc_send_buf, buffer_u8, byte);
        }
        break;
    }
}

// Send off the formatted packet
network_send_udp_raw(osc_send_socket, osc_send_url, osc_send_port, osc_send_buf,
    buffer_tell(osc_send_buf));

// Clean up
buffer_delete(buf_tmp);
