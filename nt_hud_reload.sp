#pragma semicolon 1

#include <sourcemod>

#define PLUGIN_VERSION "1.1.1"

new roundsSinceHudReload;

new bool:g_isRoundStartHooked;

new Handle:cvar_Behaviour;

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
	RegConsoleCmd("sm_hud", Command_HudReload);
	
	cvar_Behaviour = CreateConVar("sm_hud_behaviour", "0", "When should the plugin automatically reload players' HUD. 0: only reload when player uses !hud. Otherwise, reload every X rounds.", _, true, 0.0);
	HookConVarChange(cvar_Behaviour, CvarCallback_Behaviour);
}

public OnConfigsExecuted()
{
	if (GetConVarInt(cvar_Behaviour))
	{
		HookEvent("game_round_start", Event_RoundStart);
		g_isRoundStartHooked = true;
	}
}

public CvarCallback_Behaviour(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (g_isRoundStartHooked && !GetConVarInt(cvar_Behaviour))
	{
		UnhookEvent("game_round_start", Event_RoundStart);
		g_isRoundStartHooked = false;
		roundsSinceHudReload = 0;
	}
	
	else if (!g_isRoundStartHooked && GetConVarInt(cvar_Behaviour))
		HookEvent("game_round_start", Event_RoundStart);
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	roundsSinceHudReload++;
	
	if (roundsSinceHudReload == GetConVarInt(cvar_Behaviour))
	{
		roundsSinceHudReload = 0;
		
		for (new i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i))
				continue;
			
			Command_HudReload(i, 1);
		}
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
	if (IsValidClient(client))
		ClientCommand(client, "hud_reloadscheme");
}

bool:IsValidClient(client)
{
	if (client > 0 && client <= MaxClients && IsClientConnected(client) && !IsFakeClient(client))
		return true;
	
	return false;
}
