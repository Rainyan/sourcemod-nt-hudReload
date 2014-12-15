#pragma semicolon 1

#include <sourcemod>

#define PLUGIN_VERSION "1.0"

public Plugin:myinfo =
{
	name	 	=	"Automatic hud_reloadscheme",
	description	=	"Execute hud_reloadscheme every round start for everyone",
	author		=	"Rain",
	version		=	PLUGIN_VERSION,
	url			=	"https://github.com/Rainyan/sourcemod-nt-hudReload"
};

public OnPluginStart()
{
	HookEvent("game_round_start", Event_RoundStart);
	
	RegConsoleCmd("sm_hud", Command_HudReload);
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))
			continue;
		
		Command_HudReload(i, 1);
	}
}

public Action:Command_HudReload(client, args)
{
	CreateTimer(2.0, Timer_HudReload, client); // We're using a timer for the response message to be visible before HUD reset
	
	if (args == 0)
		ReplyToCommand(client, "Reloading HUD..."); // Command initiated manually by user, respond.
}

public Action:Timer_HudReload(Handle:timer, any:client)
{
	ClientCommand(client, "hud_reloadscheme");
}

bool:IsValidClient(client)
{
	if (client > 0 && client <= MaxClients && IsClientConnected(client) && !IsFakeClient(client))
		return true;
	
	return false;
}
