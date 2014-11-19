#include <sourcemod>
#include <multicolors>
#include <cstrike>

#define PLUGIN_URL "https://github.com/ESK0"
#define PLUGIN_VERSION "1.0"
#define PLUGIN_AUTHOR "ESK0"

static String: ConfigPath[PLATFORM_MAX_PATH];

new String: TsName[32];
new String: TsDead[16];

new String: CTsName[32];
new String: CTsDead[16];

new String: Access[32];

new g_iEnable;

public Plugin:myinfo = 
{
	name = "Admin See Chat",
	author = PLUGIN_AUTHOR,
	description = "Admin can see enemy team chat",
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
}

public OnPluginStart()
{
	LoadConfig();
	AddCommandListener(OnPlayerChatTeam, "say_team");
}
public Action:OnPlayerChatTeam(client, const String:command[], args)
{
	if(g_iEnable)
	{
		new String:message[256]
		new sender = GetClientTeam(client)
		GetCmdArg(1, message, sizeof(message))
		new receiver;
		if ((client > 0) && IsClientInGame(client))
		{
			if(message[0] == 0 || IsChatTrigger())
			{
				return Plugin_Handled;
			}
			for(new i = 1; i < MaxClients; i++)
			{
				if(IsValidClient(i))
				{
					if (CheckCommandAccess(client, Access, ADMFLAG_GENERIC))
					{
						receiver = GetClientTeam(i)
						if (sender != receiver)
						{
							if (GetClientTeam(client) == CS_TEAM_CT && IsPlayerAlive(client))
							{
								CPrintToChat(i, "{blue}%s %N : %s",CTsName, client, message)
							}
							else if (GetClientTeam(client) == CS_TEAM_CT)
							{
								CPrintToChat(i, "{blue}%s%s %N : %s",CTsDead, CTsName, client, message)
							}
							else if (GetClientTeam(client) == CS_TEAM_T && IsPlayerAlive(client))
							{
								CPrintToChat(i, "{orange}%s %N : %s",TsName, client, message)
							}
							else if (GetClientTeam(client) == CS_TEAM_T)
							{
								CPrintToChat(i, "{orange}%s%s %N : %s",TsDead, TsName, client, message)
							}
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}
LoadConfig()
{
	BuildPath(Path_SM, ConfigPath, sizeof(ConfigPath), "configs/ASCHconfig.cfg");
	new Handle: hConfig = CreateKeyValues("AdminSeeChat");
	if(!FileExists(ConfigPath))
	{
		SetFailState("[AdminSeeChat] 'addons/sourcemod/ASCHconfig.cfg' not found!");
		return;
	}
	FileToKeyValues(hConfig, ConfigPath);
	if(KvJumpToKey(hConfig, "Settings"))
	{
		g_iEnable = KvGetNum(hConfig, "Enable", 1);
		KvGetString(hConfig, "Ts Name", TsName, sizeof(TsName));
		KvGetString(hConfig, "Ts DeadTag", TsDead, sizeof(TsDead));
		KvGetString(hConfig, "CTs Name", CTsName, sizeof(CTsName));
		KvGetString(hConfig, "CTs DeadTag", CTsDead, sizeof(CTsDead));
		KvGetString(hConfig, "Command access", Access, sizeof(Access));
	}
	else
	{
		SetFailState("Config for 'AdminSeeChat' not found!");
		return;
	}
}


// STOCK
stock bool:IsValidClient(client, bool:alive = false)
{
    if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (alive == false || IsPlayerAlive(client)))
    {
        return true;
    }
   
    return false;
}