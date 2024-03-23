class ssHG expands Mutator config(HGuard);

var config string CheatProcs[200];
var config string CheatMods[200];
var config string KMods[200];
var config string KProcs[200];
var config string ThumbPrint[200];

var config int SecLevel, CheckInterval, TweakSecLevel;
var config string DLLLocation;
var config bool AllowNonWindows;
var config string HelpLocation;
var config bool LogNonWindows, LogPlayersInfo, LogWhiteListKicks;
var config bool AllowUnknownMods, AllowUnknownProcs;
var config string CurrentVersion;
var config bool ShowVersion;
var config bool LogProcs, LogMods, LogTweaks;

var int	   zzNumCheatProcs;
var int	   zzNumCheatMods;
var int	   zzNumKMods;
var int	   zzNumKProcs;
var int	   zzNumThumbPrint;

var bool zzbInitialized, zzSaveDone;

var ssHGInfoLog	zzHGLogFile;

var Pawn	zzPlayer[64];
var ssHGPRI	zzHGPRI[64];
var string	zzPlayerName[64];
var string	zzPlayerIP[64];

struct PlayerLists
{
	var string	zzPProcs[200];
	var string	zzPMods[200];
	var string	zzPTweaks[200];
};

var PlayerLists zzPLists[64];


// ==================================================================================
// PostBeginPlay
// ==================================================================================
function PostBeginPlay()
{
	local int zzi;

	Super.PostBeginPlay();

	if(!zzbInitialized)
	{
//		Log("FileSize = "$FileSize);

		zzbInitialized=True;
		zzSaveDone=False;

		for (zzi=0; zzi<64; zzi++)
		{
			zzPlayerName[zzi]="";
			zzPlayerIP[zzi]="";
		}

		if (CurrentVersion == "")
		{
			Log("Warning, the HGuard.ini values did not load properly!");
		}

		SetTimer(1.0, True);
	}

	Disable('Tick');
}

// ==================================================================================
// Timer
// ==================================================================================
event Timer()
{
	local int zzi, zzPID;
	local Pawn zzP;
	local PlayerPawn zzPP;
	local ssHGPRI zzPRI;

	// Close the log when game ends
	if ( (Level.Game.bGameEnded || Level.NextSwitchCountdown < 1.5) && !zzSaveDone)
	{
		xxSaveAllPlayerInfo();
	}

	// Clean up after player who have left.
	for (zzi=0; zzi<64; zzi++)
	{
		if ( (zzPlayer[zzi] != None) && (zzPlayer[zzi].bDeleteMe) && (zzHGPRI[zzi] != None) )
		{
			zzPlayer[zzi] = None;
			zzHGPRI[zzi].Destroy();
			zzHGPRI[zzi] = None;
		}
	}

	// Part 2: Finding Players who haven't been checked and checking them
	for( zzP=Level.PawnList; (zzP!=None) && (Level!=None) && (Level.PawnList!=None); zzP=zzP.NextPawn )
	{
		if ( (zzP.bIsPlayer) && (!zzP.bDeleteMe) && (PlayerPawn(zzP) != None) )
		{
			zzPP = PlayerPawn(zzP);
			if ((zzPP.PlayerReplicationInfo != None) && (!zzP.PlayerReplicationInfo.bIsABot) && 
					(!zzP.PlayerReplicationInfo.bIsSpectator) && (NetConnection(zzPP.Player) != None) )
			{
				zzPID = zzPP.PlayerReplicationInfo.PlayerID;
//				if (xxFindPIndexFor(zzP) == -1) 
				if (zzPlayerName[zzPID] == "" && zzPlayer[zzPID] == None && zzHGPRI[zzPID] == None) 
				{
					zzPRI = Spawn(Class 'ssHGPRI', zzP,, zzP.Location);
					if ( zzPRI != None )
					{
						// Init newHGPRI
/*			 			zzi = 0;
						while ( (zzi<32) && (zzPlayer[zzi] != None) )
						  zzi++;

						zzPlayer[zzi] = zzP;
						zzHGPRI[zzi] = zzPRI;
*/
						zzPlayer[zzPID] = zzP;
						zzHGPRI[zzPID] = zzPRI;

						zzPlayerName[zzPID] = zzP.PlayerReplicationInfo.PlayerName;
						zzPlayerIP[zzPID]=zzPP.GetPlayerNetworkAddress();
						zzPlayerIP[zzPID]=Left(zzPlayerIP[zzPID], InStr(zzPlayerIP[zzPID], ":"));

						Log("[HG] Spawning PRI for "$zzPlayerName[zzPID]$" index = "$zzPID);

						for (zzi=0; zzi<200 && CheatProcs[zzi]!=""; zzi++)
						{
							 zzPRI.zzCheatProcs[zzi] = CheatProcs[zzi];
						}
						zzPRI.zzNumCheatProcs = zzi;

						for (zzi=0; zzi<200 && CheatMods[zzi]!=""; zzi++)
						{
							 zzPRI.zzCheatMods[zzi] = CheatMods[zzi];
						}
						zzPRI.zzNumCheatMods = zzi;

						for (zzi=0; zzi<200 && KMods[zzi]!=""; zzi++)
						{
							 zzPRI.zzKMods[zzi] = KMods[zzi];
						}
						zzPRI.zzNumKMods = zzi;

						for (zzi=0; zzi<200 && KProcs[zzi]!=""; zzi++)
						{
							 zzPRI.zzKProcs[zzi] = KProcs[zzi];
						}
						zzPRI.zzNumKProcs = zzi;


						for (zzi=0; zzi<200 && ThumbPrint[zzi]!=""; zzi++)
						{
							 zzPRI.zzThumbPrint[zzi] = ThumbPrint[zzi];
						}
						zzPRI.zzNumThumbPrint = zzi;

						zzPRI.zzCheckInterval = CheckInterval;
						zzPRI.zzDLLLocation = DLLLocation;
						zzPRI.zzHelpLocation = HelpLocation;
						zzPRI.zzCurrentVersion = CurrentVersion;
						zzPRI.zzShowVersion = ShowVersion;
						zzPRI.zzLogNonWindows = LogNonWindows;
						zzPRI.zzAllowUnknownMods = AllowUnknownMods;
						zzPRI.zzAllowNonWindows = AllowNonWindows;
						zzPRI.zzSecLevel = SecLevel;
						zzPRI.zzTweakSecLevel = TweakSecLevel;
						zzPRI.zzLogProcs = LogProcs;
						zzPRI.zzLogMods = LogMods;
						zzPRI.zzLogTweaks = LogTweaks;

						zzPRI.zzMyMutie = Self;

						zzPRI.zzDone = True;

						zzPRI.xxStartTimer();
					}
				}
 			}
		}
	}
}

// ==================================================================================
// xxStoreProc
// ==================================================================================
function xxStoreProc(int zzPID, string zzProcString, int zzIndex)
{
	zzPLists[zzPID].zzPProcs[zzIndex] = zzProcString;
//	Log("xxStoreProc(), zzPID = "$zzPID$" zzProcString = "$zzProcString$" zzIndex = "$zzIndex);
}

// ==================================================================================
// xxStoreMod
// ==================================================================================
function xxStoreMod(int zzPID, string zzModString, int zzIndex)
{
	zzPLists[zzPID].zzPMods[zzIndex] = zzModString;
//	Log("xxStoreMod(), zzModString = "$zzModString$" zzIndex = "$zzIndex);
}

// ==================================================================================
// xxStoreMod
// ==================================================================================
function xxStoreTweak(int zzPID, string zzProcString, int zzIndex)
{
	zzPLists[zzPID].zzPTweaks[zzIndex] = zzProcString;
//	Log("xxStoreProc(), zzProcString = "$zzProcString);
}


// ==================================================================================
// HGInfoLog
// ==================================================================================
function xxHGInfoLog(string zzs)
{	
	if (zzHGLogFile != None)
	{
		zzHGLogFile.LogEventString(zzs);
		zzHGLogFile.FileFlush();
	}
}

// ==================================================================================
// xxSaveAllPlayerInfo
// ==================================================================================
function xxSaveAllPlayerInfo()
{
	local int zzi, zzj;
	local string zzModList, zzProcList, zzTweakList;

	zzSaveDone = True;

	if (LogPlayersInfo == FALSE)
		return;

	for (zzi=0; zzi<64; zzi++)
	{
		zzProcList = "";
		zzModList = "";
		zzTweakList = "";

		if ( zzPlayerName[zzi] == "" )
			continue;

		Log("xxSaveAllPlayerInfo()(), zzPlayerName["$zzi$"] = "$zzPlayerName[zzi]);

		for(zzj=0; (zzj<200) && (zzPLists[zzi].zzPProcs[zzj] != ""); zzj++)
		{
			if ( zzj > 0)
			{
				zzProcList = ""$zzProcList$","$zzPLists[zzi].zzPProcs[zzj];
			}
			else
			{
				zzProcList = zzPLists[zzi].zzPProcs[zzj];
			}
		}
		for(zzj=0; zzj<200 && zzPLists[zzi].zzPMods[zzj] != ""; zzj++)
		{
			if ( zzj > 0)
			{
				zzModList = ""$zzModList$","$zzPLists[zzi].zzPMods[zzj];
			}
			else
			{
				zzModList = zzPLists[zzi].zzPMods[zzj];
			}
		}
		for(zzj=0; zzj<200 && zzPLists[zzi].zzPTweaks[zzj] != "";zzj++)
		{
			if ( zzj > 0)
			{
				zzTweakList = ""$zzTweakList$","$zzPLists[zzi].zzPTweaks[zzj];
			}
			else
			{
				zzTweakList = zzPLists[zzi].zzPTweaks[zzj];
			}
		}

		if (zzHGLogFile == None)
		{
			zzHGLogFile = spawn(class 'ssHGInfoLog');
			if (zzHGLogFile != None)
			{
				zzHGLogFile.StartLog();
			} 
			else 
			{
				return;
			}
		}

//			xxHGInfoLog(""$zzPlayerName[zzIndex]$", "$zzPlayerIP[zzIndex]$", Processes="$zzProcList$Chr(13)$", Modules="$zzModList$Chr(13)$", Tweaks="$zzTweakList)$Chr(13));
//			xxHGInfoLog(""$zzPlayerName[zzIndex]$", "$zzPlayerIP[zzIndex]$", Processes="$zzProcList$Chr(13)$", Modules="$zzModList$Chr(13)$", Tweaks="$zzTweakList$Chr(13));
		xxHGInfoLog("Name-IP="$zzPlayerName[zzi]$","$zzPlayerIP[zzi]);
		xxHGInfoLog("Processes="$zzProcList);
		xxHGInfoLog("Modules="$zzModList);
		xxHGInfoLog("Tweaks="$zzTweakList);
	}

	if (zzHGLogFile != None)
	{
		zzHGLogFile.StopLog();
		zzHGLogFile.Destroy();
		zzHGLogFile = None;
	}
}

// ===================================================================
// xxDestroy
// ===================================================================

function xxDestroy(int zzPID)
{
	Pawn(Owner).Destroy();
}


defaultproperties
{
	NetPriority=5.0000000
}
