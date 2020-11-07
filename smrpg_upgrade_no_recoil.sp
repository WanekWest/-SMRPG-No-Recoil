#pragma semicolon 1
#pragma newdecls required
#include <smrpg>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>

#define UPGRADE_SHORTNAME "nprecoil"
#define PLUGIN_VERSION "1.0"

public Plugin myinfo = 
{
	name = "SM:RPG Upgrade > No Recoil",
	author = "WanekWest",
	description = "No recoil for guns.",
	version = PLUGIN_VERSION,
	url = "https://vk.com/wanek_west"
}

public void OnPluginStart()
{
	HookEvent("weapon_fire", EventWeaponFire, EventHookMode_Pre);

	LoadTranslations("smrpg_stock_upgrades.phrases");
}

public void OnPluginEnd()
{
	if(SMRPG_UpgradeExists(UPGRADE_SHORTNAME))
		SMRPG_UnregisterUpgradeType(UPGRADE_SHORTNAME);
}

public void OnAllPluginsLoaded()
{
	OnLibraryAdded("smrpg");
}

public void OnLibraryAdded(const char[] name)
{
	if(StrEqual(name, "smrpg"))
	{
		SMRPG_RegisterUpgradeType("nprecoil", UPGRADE_SHORTNAME, "No recoil for guns.", 0, true, 1, 2500, 1000);
		SMRPG_SetUpgradeTranslationCallback(UPGRADE_SHORTNAME, SMRPG_TranslateUpgrade);
	}
}

public void SMRPG_TranslateUpgrade(int client, const char[] shortname, TranslationType type, char[] translation, int maxlen)
{
	if(type == TranslationType_Name)
		Format(translation, maxlen, "%T", UPGRADE_SHORTNAME, client);
	else if(type == TranslationType_Description)
	{
		char sDescriptionKey[MAX_UPGRADE_SHORTNAME_LENGTH+12] = UPGRADE_SHORTNAME;
		StrCat(sDescriptionKey, sizeof(sDescriptionKey), " description");
		Format(translation, maxlen, "%T", sDescriptionKey, client);
	}
}

void EventWeaponFire(Event hEvent, const char[] sEvName, bool bdontBoadcast)
{
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));

	char sBuf[32];
	hEvent.GetString("weapon", sBuf, sizeof sBuf);

	if(iClient && SMRPG_GetClientUpgradeLevel(iClient, UPGRADE_SHORTNAME) > 0)
	{
		int iActiveWeapon = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
		
		if (iActiveWeapon != -1 && IsValidEdict(iActiveWeapon)) 
		{
			SetEntPropFloat(iActiveWeapon,Prop_Send,"m_fAccuracyPenalty", -5000000.0);
			SetEntPropVector(iClient, Prop_Send, "m_viewPunchAngle", view_as<float>({0.0, 0.0, 0.0}));
			SetEntPropVector(iClient, Prop_Send, "m_aimPunchAngle", view_as<float>({0.0, 0.0, 0.0}));
			SetEntPropVector(iClient, Prop_Send, "m_aimPunchAngleVel", view_as<float>({0.0, 0.0, 0.0}));
		}
	}
}