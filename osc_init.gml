/* Initialize OSC settings.
 * This must be called before any other OSC functions.
 * Usage:
 *   osc_init("127.0.0.1", 8140, 8142);
 */

// Validate args
if (argument_count < 3) {
    show_error("osc_init(): Not enough arguments.", true);
}
osc_send_url = argument[0];
osc_send_port = argument[1];
osc_listen_port = argument[2];
if (!is_string(osc_send_url)) {
    show_error("osc_init(): Expected URL (string) at argument 0.", true);
}
else if (!is_real(osc_send_port)) {
    show_error("osc_init(): Expected send port (number) at argument 1.", true);
}
else if (!is_real(osc_listen_port)) {
    show_error("osc_init(): Expected listen port (number) at argument 2.", true);
}

// Create network objects
osc_send_buf = buffer_create(512, buffer_grow, 1);
osc_send_socket = network_create_socket(network_socket_udp);
osc_listen_socket = network_create_server_raw(network_socket_udp, osc_listen_port, 1);

// Set init flag
osc_is_setup = true;
