/* Initialize OSC settings.
 * This must be called before any other OSC functions.
 * Only OSC client is implemented, not server.
 * Usage:
 *   osc_init("127.0.0.1", 8140);
 */

// Validate args
if (argument_count < 2) {
    show_error("osc_init(): Not enough arguments.", true);
}

// OSC network settings
osc_socket = network_create_socket(network_socket_udp);
osc_url = argument[0];
osc_port = argument[1];
if (!is_string(osc_url)) {
    show_error("osc_init(): Expected URL (string) at argument 0.", true);
}
else if (!is_real(osc_port)) {
    show_error("osc_init(): Expected port (number) at argument 1.", true);
}

// Buffer to hold messages
osc_buf = buffer_create(512, buffer_grow, 1);

// Set init flag
osc_is_setup = true;
