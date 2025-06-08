#include <amxmodx>

#define PLUGIN "Anti Scam"
#define VERSION "1.1"
#define AUTHOR "GonsanZ"

// Lista de dominios sospechosos
new const scam_keywords[][] = {
    ".ru", ".tk", ".ml", "discordgift.com", "free-sk.in", "csgoprize", "freeskins", "steamcom", "steamnity"
};

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_clcmd("say", "check_message");
    register_clcmd("say_team", "check_message");
}

public check_message(id)
{
    new msg[192];
    read_args(msg, charsmax(msg));
    remove_quotes(msg);
    strtolower(msg); // Comparación sin mayúsculas

    for (new i = 0; i < sizeof scam_keywords; i++)
    {
        if (contain(msg, scam_keywords[i]) != -1)
        {
            // Info del jugador
            new name[32], ip[32];
            get_user_name(id, name, charsmax(name));
            get_user_ip(id, ip, charsmax(ip), 1);

            // Avisar al jugador
            client_print(id, print_chat, "[AntiScam] Tu mensaje fue bloqueado por contener enlaces sospechosos.");

            // Loguear en archivo
            log_to_file("addons/amxmodx/logs/antiscam.log",
                "[AntiScam] %s [%s] intentó enviar: ^"%s^"", name, ip, msg);

            // Notificar a los administradores conectados
            notify_admins(name, ip, msg);

            return PLUGIN_HANDLED; // Bloquea el mensaje
        }
    }

    return PLUGIN_CONTINUE;
}

// Enviar notificación a los admins con ADMIN_KICK o mayor
stock notify_admins(const name[], const ip[], const msg[])
{
    new players[32], num;
    get_players(players, num);

    for (new i = 0; i < num; i++)
    {
        if (get_user_flags(players[i]) & ADMIN_KICK)
        {
            client_print(players[i], print_chat,
                "[AntiScam] Jugador: %s | IP: %s | Mensaje sospechoso: %s",
                name, ip, msg);
        }
    }
}
