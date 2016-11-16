#pragma semicolon 1

#include <sourcemod>
#include <neotokyo>

#define PLUGIN_VERSION "1.2"

int g_iRoundCount;

bool g_bIsRoundStartHooked;

Handle g_hCvar_Behaviour;

public Plugin myinfo = {
	name	 			=	"Automatic hud_reloadscheme",
	description	=	"Execute hud_reloadscheme every round start for everyone",
	author			=	"Rain",
	version			=	PLUGIN_VERSION,
	url					=	"https://github.com/Rainyan/sourcemod-nt-hudReload"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_hud", Command_HudReload);

	g_hCvar_Behaviour = CreateConVar("sm_hud_behaviour", "0", "When should the plugin automatically reload players' HUD. 0: only reload when player uses sm_hud. Otherwise, reload every X rounds.", _, true, 0.0);
	HookConVarChange(g_hCvar_Behaviour, CvarCallback_Behaviour);

	AutoExecConfig(true);
}

public void OnConfigsExecuted()
{
	if (GetConVarInt(g_hCvar_Behaviour) > 0)
	{
		HookEvent("game_round_start", Event_RoundStart);
		g_bIsRoundStartHooked = true;
	}
}

public void CvarCallback_Behaviour(Handle cvar, const char[] oldVal, const char[] newVal)
{
	int iNew = StringToInt(newVal);
	if (g_bIsRoundStartHooked && iNew == 0)
	{
		UnhookEvent("game_round_start", Event_RoundStart);
		g_bIsRoundStartHooked = false;
		g_iRoundCount = 0;
	}
	else if (!g_bIsRoundStartHooked && iNew > 0)
	{
		HookEvent("game_round_start", Event_RoundStart);
		g_bIsRoundStartHooked = true;
	}
}

public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	g_iRoundCount++;
	if (g_iRoundCount < GetConVarInt(g_hCvar_Behaviour))
		return Plugin_Continue;

	PrintToServer("TRIG!!");

	for (int i = 1; i <= MaxClients; i++)
	{
		// Client validity is checked by the function
		ReloadHud(i);
	}
	g_iRoundCount = 0;

	return Plugin_Handled;
}

public Action Command_HudReload(int client, int args)
{
	// Timer before reloading HUD, because the HUD reload momentarily breaks chat
	CreateTimer(2.0, Timer_HudReload, client);
	ReplyToCommand(client, "Reloading HUD! This may break the chat for a couple of seconds...");

	return Plugin_Handled;
}

public Action Timer_HudReload(Handle timer, any client)
{
	ReloadHud(client);
}

void ReloadHud(int client)
{
	if (!IsValidClient(client) || IsFakeClient(client))
		return;

	ClientCommand(client, "hud_reloadscheme");
}
