#include <sourcemod>
#include <multicolors>
#include <cstrike>

#define PLUGIN_URL "https://github.com/ESK0"
#define PLUGIN_VERSION "1.0"
#define PLUGIN_AUTHOR "ESK0"

char ConfigPath[PLATFORM_MAX_PATH];

char TsName[32];
char TsDead[16];

char CTsName[32];
char CTsDead[16];

char Access[32];

int g_iEnable;

public Plugin myinfo =
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
public Action OnPlayerChatTeam(client, const char[] command, args)
{
	if(g_iEnable)
	{
		char message[256];
		int sender = GetClientTeam(client);
		int receiver;
		GetCmdArg(1, message, sizeof(message));
		if (IsValidClient(client))
		{
			if(message[0] == '/' || message[0] == '@' || message[0] == 0)
			{
				return Plugin_Handled;
			}
			for(int i = 1; i < MaxClients; i++)
			{
				if(IsValidClient(i))
				{
					if(CheckCommandAccess(i, Access, ADMFLAG_GENERIC))
					{
						receiver = GetClientTeam(i);
						if (sender != receiver)
						{
							CPrintToChat(i, "%s%s%s %N : %s",
								(sender == CS_TEAM_CT) ? "{blue}" : (sender == CS_TEAM_T) ? "{orange}" : "{gray}",
								IsPlayerAlive(client) ? "" : (sender == CS_TEAM_T) ? TsDead : (sender == CS_TEAM_CT) ? CTsDead : "",
								(sender == CS_TEAM_CT) ? CTsName : (sender == CS_TEAM_T) ? TsName : "", client, message);
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}
public LoadConfig()
{
	BuildPath(Path_SM, ConfigPath, sizeof(ConfigPath), "configs/ASCHconfig.cfg");
	Handle hConfig = CreateKeyValues("AdminSeeChat");
	if(!FileExists(ConfigPath))
	{
		SetFailState("[AdminSeeChat] 'addons/sourcemod/configs/ASCHconfig.cfg' not found!");
		return;
	}
	FileToKeyValues(hConfig, ConfigPath);
	if(KvJumpToKey(hConfig, "Settings"))
	{
		g_iEnable = KvGetNum(hConfig, "Enable", 1);
		KvGetString(hConfig, "Ts_Name", TsName, sizeof(TsName), "(Terrorists)");
		KvGetString(hConfig, "Ts_DeadTag", TsDead, sizeof(TsDead), "*DEAD*");
		KvGetString(hConfig, "CTs_Name", CTsName, sizeof(CTsName), "(Counter-Terrorists)");
		KvGetString(hConfig, "CTs_DeadTag", CTsDead, sizeof(CTsDead), "*DEAD*");
		KvGetString(hConfig, "Command_access", Access, sizeof(Access), "sm_admin");
	}
	else
	{
		SetFailState("Config for 'AdminSeeChat' not found!");
		return;
	}
}
stock bool IsValidClient(client, bool alive = false)
{
    if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (alive == false || IsPlayerAlive(client)))
    {
        return true;
    }
    return false;
}
