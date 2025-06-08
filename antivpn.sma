#include <amxmodx>
#include <sockets> // o usa curl si tienes el módulo
#include <geoip>

#define PLUGIN "AntiVPN"
#define VERSION "1.0"
#define AUTHOR "GonsanZ"

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
}

public client_authorized(id)
{
    new ip[32];
    get_user_ip(id, ip, charsmax(ip), 1);

    // Elimina puerto si tiene
    new ip_clean[32];
    strtok(ip, ip_clean, charsmax(ip_clean), "", 0, ':');

    // Consulta la IP a ip-api.com (formato JSON)
    new url[128];
    formatex(url, charsmax(url), "http://ip-api.com/json/%s?fields=proxy", ip_clean);
    query_vpn_check(id, url);
}

stock query_vpn_check(id, const url[])
{
    new socket = socket_open(url, SOCKET_TCP, query_callback, id);
    if (socket <= 0)
    {
        server_print("[AntiVPN] Error al conectar con el servidor VPN.");
        return;
    }
}

// Callback cuando se recibe respuesta
public query_callback(socket, const data[], len, id)
{
    new result[512];
    copy(result, charsmax(result), data);

    // Busca "proxy":true o "proxy":false
    if (containi(result, "\"proxy\":true") != -1)
    {
        new name[32];
        get_user_name(id, name, charsmax(name));
        server_cmd("kick #%d ^"Se detectó uso de VPN. Conexión denegada.^"", get_user_userid(id));
        server_print("[AntiVPN] Usuario %s expulsado por VPN.", name);
    }

    socket_close(socket);
}
