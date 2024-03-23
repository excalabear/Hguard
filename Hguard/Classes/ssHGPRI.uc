class ssHGPRI expands ReplicationInfo;

var ssHG 	zzMyMutie;
var string 	zzFile, zzName;
var string 	zzDLLLocation, zzHelpLocation;
var string	zzCurrentVersion;

var int 	zzCount, zzTimer, zzCheckInterval, zzSecLevel, zzTweakSecLevel;

var bool 	zzWelcomed, zzDone, zzFirstTime, zzbInitialized;
var bool 	zzKick, zzLogNonWindows, zzAllowNonWindows, zzAllowUnknownMods;
var bool 	zzLogProcs, zzLogMods, zzLogTweaks, zzShowVersion;

var string 	zzProcs, zzMods, zzTweaks;

var() class <UWindowWindow> WindowClass;
var() int WinLeft, WinTop, WinWidth,WinHeight;

var UWindowWindow TheWindow;

var() string	zzPProcs[200];
var() string	zzPMods[200];
var() string	zzPTweaks[200];

var() int		zzMemSize[200];
var() int		zzVariance[200];
var() int		zzDependencies[200];
var() int		zzDepVar[200];

var() string 	zzCheatProcs[200];
var() string 	zzCheatMods[200];
var() string 	zzKMods[200];
var() string 	zzKProcs[200];
var() string 	zzThumbPrint[200];

var int	   		zzNumCheatProcs;
var int	   		zzNumCheatMods;
var int	   		zzNumKMods;
var int	   		zzNumKProcs;
var int	   		zzNumThumbPrint;

var ssHGFileMagic zzFMVersion, zzFMProcs, zzFMMods, zzFMTweaks;

var PlayerPawn zzPPawn;
var WindowConsole zzPConsole;

replication
{
	// Functions the client calls on the server.
	reliable if ( ROLE < ROLE_Authority)
		xxStoreProcsOnServer, xxStoreModsOnServer, xxStoreTweaksOnServer, 
		xxLogHacker, xxBanHacker, xxKickClient, xxLogWhiteListKick, xxLogNonwindowsPlayer,
		xxSetInitState, xxDestroyPlayer;

	// Functions the server calls on the client.
	reliable if ( ROLE == ROLE_Authority)
		xxCheckReplication, xxGetOS, xxGetDLLVersion, xxCreateThumbPrints, xxWelcomeMessage,
		xxCheckProcesses, xxCheckUTModules, xxCheckTweaks, xxKickPlayer;

	// Data on the client that is accessable by the server
	reliable if ( ROLE == ROLE_Authority)
		zzCheatProcs, zzCheatMods, zzKMods, zzKProcs, zzThumbPrint, zzCheckInterval, zzDLLLocation,
		zzHelpLocation, zzCurrentVersion, zzShowVersion, zzDone, zzNumCheatProcs, zzNumCheatMods,
		zzNumKProcs, zzNumKMods, zzNumThumbPrint, zzLogNonWindows, zzAllowNonWindows, zzAllowUnknownMods,
		zzLogProcs, zzLogMods, zzLogTweaks, zzWelcomed, zzSecLevel, zzTweakSecLevel;

	// Data on the Server that is replicated to the client.
	reliable if ( ROLE == ROLE_Authority)
		zzbInitialized;

}

// ==================================================================================
// PostBeginPlay
// ==================================================================================
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	zzCount = 0;
	zzTimer = 0;
	zzWelcomed = False;
	zzbInitialized = False;
	zzFirstTime = True;
	zzKick = False;

	Disable('Tick');

	zzFMVersion = new Class 'ssHGFileMagic';
	zzFMProcs = new Class 'ssHGFileMagic';
	zzFMMods = new Class 'ssHGFileMagic';
	zzFMTweaks = new Class 'ssHGFileMagic';
}


// ==================================================================================
// xxStartTimer
// ==================================================================================
simulated function xxStartTimer()
{
	SetTimer(1.000, True);
}

// ==================================================================================
// Timer
// ==================================================================================
simulated function Timer()
{
//	Log("Timer(), zzTimer = "$zzTimer);

	if ( zzKick )
		zzCount++;

	if ( zzCount > 2)
	{
//		zzMyMutie.xxDestroy(PlayerPawn(Owner).PlayerReplicationInfo.PlayerID);
		xxKickPlayer();
	}

	if ( !zzbInitialized )
	{
		zzTimer++;
		if ( zzTimer > 30 )
		{
//			zzMyMutie.xxDestroy(PlayerPawn(Owner).PlayerReplicationInfo.PlayerID);
			xxKickPlayer();
		}
		xxCheckReplication();
		return;
	}

	zzPPawn = PlayerPawn(Owner);
	if (zzPPawn==None)
	{
		Log("HGPRI PlayerPawn(Owner) = None!");
		return;
	}

	if ( zzbInitialized && !zzKick )
	{
		if ( zzFirstTime )
		{
			zzFirstTime = False;
			xxGetOS();
			xxGetDLLVersion();
			xxCreateThumbPrints();
			xxCheckProcesses();
			xxCheckUTModules();
			xxCheckTweaks();
			xxWelcomeMessage();
			zzTimer = 0;
		}
		else
		{
			zzTimer++;
			if ( zzTimer >= zzCheckInterval )
			{
				zzTimer = 0;
				xxCheckProcesses();
				xxCheckUTModules();
				xxCheckTweaks();
			}
		}
	}
}

// ==================================================================================
// xxCheckReplication
// ==================================================================================
simulated function xxSetInitState(bool zzState)
{
	zzbInitialized = zzState;
}

// ==================================================================================
// xxCheckReplication
// ==================================================================================
simulated function xxCheckReplication()
{
	local int zzi;
	local bool zzRepDone;

	zzRepDone = True;

	for (zzi=0; zzi<200 && zzCheatProcs[zzi]!=""; zzi++) {}
	if ( (zzNumCheatProcs != zzi) && (zzi != 0) )
	{
		zzRepDone = False;
	}

	for (zzi=0; zzi<200 && zzCheatMods[zzi]!=""; zzi++) {}
	if ( (zzNumCheatMods != zzi) && (zzi != 0) )
	{
		zzRepDone = False;
	}

	for (zzi=0; zzi<200 && zzKMods[zzi]!=""; zzi++) {}
	if ( (zzNumKMods != zzi) && (zzi != 0) )
	{
		zzRepDone = False;
	}

	for (zzi=0; zzi<200 && zzKProcs[zzi]!=""; zzi++) {}
	if ( (zzNumKProcs != zzi) && (zzi != 0) )
	{
		zzRepDone = False;
	}

	for (zzi=0; zzi<200 && zzThumbPrint[zzi]!=""; zzi++) {}
	if ( (zzNumThumbPrint != zzi) && (zzi != 0) )
	{
		zzRepDone = False;
	}

	if ( zzDone == False || zzDLLLocation == "" || zzHelpLocation == "")
	{
		Log ("DLLLocation or zzHelpLocation is not set to anything");
		zzRepDone = False;
	}

	xxSetInitState(zzRepDone);
}

// ==================================================================================
// xxCreateThumbPrints
// ==================================================================================
simulated function xxCreateThumbPrints()
{
	local int zzi, zzpos;
	local string zzLongString, zzShortString;
	
	if ( zzKick )
		return;

	for (zzi=0; zzi<200 && zzThumbPrint[zzi]!=""; zzi++)
	{
		zzLongString = zzThumbPrint[zzi];

		zzpos = InStr(zzLongString, ",");
		zzShortString = Left(zzLongString, zzpos);
		zzLongString = Mid(zzLongString, zzpos+1);
		zzMemSize[zzi] = int(zzShortString); 

		zzpos = InStr(zzLongString, ",");
		zzShortString = Left(zzLongString, zzpos);
		zzLongString = Mid(zzLongString, zzpos+1);
		zzVariance[zzi] = int(zzShortString); 

		zzpos = InStr(zzLongString, ",");
		zzShortString = Left(zzLongString, zzpos);
		zzLongString = Mid(zzLongString, zzpos+1);
		zzDependencies[zzi] = int(zzShortString); 

		zzDepVar[zzi] = int(zzLongString);

//		Log("zzMemSize = "$zzMemSize[zzi]$" zzVariance = "$zzVariance[zzi]$" zzDependencies = "$zzDependencies[zzi]$" zzDepVar = "$zzDepVar[zzi]);
	}
}

// ==================================================================================
// xxWelcomeMessage
// ==================================================================================
simulated function xxWelcomeMessage()
{
	if  ( !zzWelcomed && !zzKick )
	{
		zzWelcomed = True;
		PlayerPawn(Owner).ClientMessage(""$zzName$" running UBrowser.dll version "$zzCurrentVersion);
	}
}

// ==================================================================================
// xxGetOS
// ==================================================================================
simulated function xxGetOS()
{
	local PlayerPawn zzMyPlayer;
	local int zzOSNumber;

	zzOSNumber = 0;

	zzMyPlayer = PlayerPawn(Owner);

	//MAC=1, WINDOWS=2, LINUX=3
	if( instr(caps(""$zzMyPlayer.Player.Class),"MACVIEWPORT")>-1)
	{
		zzOSNumber = 1;
	}
	else if (instr(caps(""$zzMyPlayer.Player.Class),"WINDOWSVIEWPORT")>-1)
	{
		zzOSNumber = 2;
	}
	else
	{
		zzOSNumber = 3;
	}

	if ( zzOSNumber == 0 )
	{
		xxNoOS();
	}
	else if ( zzOSNumber == 1 || zzOSNumber == 3 )
	{
		xxNotWindows();
	}
}

//==================================================================================
// xxNotWindows
// ==================================================================================
simulated function xxNotWindows()
{
	local string zzMsg, zzTitle, zzHL;
	local PlayerPawn zzPP;
	local int zzPID;

	zzPP = PlayerPawn(Owner);
	if (zzPP==None)
	{
		return;
	}

	zzPID = PlayerPawn(Owner).PlayerReplicationInfo.PlayerID;

	// Player not using windows, allow non-windows players?
	if (zzLogNonWindows == TRUE)
	{
		xxLogNonwindowsPlayer(zzPID);
	}

	if (zzAllowNonWindows == FALSE)
	{
		zzHL = zzHelpLocation;

		zzMsg = "This server is currently configured to allow only Windows clients!!!"$Chr(13)$Chr(13);
		zzMsg = zzMsg$"Click on OK to be taken to "$Chr(13)$Chr(13);
		zzMsg = zzMsg$zzHL$Chr(13)$Chr(13);
		zzMsg = zzMsg$"for help or questions.";

		zzTitle = "HGuard Message";

		OpenMsgWindow(0, zzMsg, zzTitle, zzHL);

		xxKickClient();
	}
}

//==================================================================================
// xxNotWindows
// ==================================================================================
simulated function xxNoOS()
{
	local string zzMsg, zzTitle, zzHL;

	zzHL = zzHelpLocation;

	zzMsg = "Your operating system was unrecognizeable. Therefore you have been kicked from the server."$Chr(13)$Chr(13);;
	zzMsg = zzMsg$"Click on OK to be taken to "$Chr(13)$Chr(13);
	zzMsg = zzMsg$zzHL$Chr(13)$Chr(13);
	zzMsg = zzMsg$"for help or questions.";

	zzTitle = "HGuard Error";

	OpenMsgWindow(0, zzMsg, zzTitle, zzHL);

	xxKickClient();
}

// ==================================================================================
// xxGetDLLVersion
// ==================================================================================
simulated function xxGetDLLVersion()
{
	local ssHGFileMagic zzFM;
	local string zzlist;
	local string zzMsg, zzType;
//	local bool zzKickPlayer;

	if ( zzKick )
		return;

	zzFMVersion.zzFile = "";		   
//	zzFM.zzFound = False;

	zzFMVersion.IncludeBinaryFile("version.txt");

	if (zzFMVersion.zzFile == "")
	{
		zzlist = "Empty";
	}
	else
	{
		zzlist = zzFMVersion.zzFile;
	}

//	zzKickPlayer = False;

	if (zzlist == "" || zzlist == "Missing")
	{
		zzType = "download";
		zzKick = True;
	}
	else if (zzlist != zzCurrentVersion)
	{
		zzType = "upgrade";
		zzKick = True;
	}

	if ( zzKick )
	{
		zzMsg = "You need to "$zzType$" a dll to join and play on this server."$Chr(13)$Chr(13);
		zzMsg = zzMsg$"Save this file in C:\\TournamentDemo\\System and restart Unreal after the download is complete."$Chr(13)$Chr(13);
		//	zzURL = ""$zzURL$" The default install location for Unreal Tournament Demo is in the C:\\TournamentDemo directory.";
		//	zzURL = ""$zzURL$" You will need to restart Unreal after downloading the file.";
//		zzMsg = zzMsg$"You will need to restart Unreal after downloading the file."$Chr(13)$Chr(13);
		zzMsg = zzMsg$"Click on the OK button to proceed with the download."$Chr(13)$Chr(13);
		zzMsg = zzMsg$"If there is a problem with this automated link, you can download the file manually here:"$Chr(13)$Chr(13);
		zzMsg = zzMsg$zzDLLLocation$Chr(13)$Chr(13);
		zzMsg = zzMsg$"If you need support, go here :"$Chr(13)$Chr(13);
		zzMsg = zzMsg$zzHelpLocation$Chr(13)$Chr(13);

		OpenMsgWindow(0, zzMsg, "HGuard Message", zzDLLLocation);

		xxKickClient();
	}
}

// ===================================================================
// xxLogNonwindows
// ===================================================================
function xxLogNonwindowsPlayer(int zzIndex)
{
	local int zzPID;
	local ssHGNWindowsLog zzHGNWLog;

	zzHGNWLog = spawn(class 'ssHGNWindowsLog');

	zzHGNWLog.StartLog();

	zzPID = PlayerPawn(Owner).PlayerReplicationInfo.PlayerID;

	zzHGNWLog.LogEventString("PlayerName = "$zzMyMutie.zzPlayerName[zzPID]);
	zzHGNWLog.FileFlush();
	zzHGNWLog.LogEventString("PlayerIP = "$zzMyMutie.zzPlayerIP[zzPID]);
	zzHGNWLog.FileFlush();

	zzHGNWLog.StopLog();
	zzHGNWLog.Destroy();
	zzHGNWLog = None;
}

//==================================================================================
// xxNotWindows
// ==================================================================================
simulated function xxMissingFile()
{
	local string zzMsg, zzTitle, zzHL;

	zzHL = zzHelpLocation;

	zzMsg = "There seems to be a problem with your UBrowser.dll. "$Chr(13)$Chr(13);;
	zzMsg = zzMsg$"Please report that HGuard could not find a data file in your UT installation ."$Chr(13)$Chr(13);;
	zzMsg = zzMsg$"Click on OK to be taken to "$Chr(13)$Chr(13);
	zzMsg = zzMsg$zzHelpLocation$Chr(13)$Chr(13);
	zzMsg = zzMsg$"for help or questions.";

	zzTitle = "HGuard Error";

	OpenMsgWindow(0, zzMsg, zzTitle, zzHL);

	xxKickClient();
}

// ==================================================================================
// xxGetProcesses
// ==================================================================================
simulated function xxCheckProcesses()
{
//	local ssHGFileMagic zzFM;
	local string zzlist;
	local string zzOriginal, zzDelimited, zzShort, zzProcInfo;
	local int zzi, zzj, zzpos, zzPID;
	local bool zzbFound;
	local string zzName;
	local int zzMem, zzMCount;

	if ( PlayerPawn(Owner) == None )
		return;

	zzPID = PlayerPawn(Owner).PlayerReplicationInfo.PlayerID;

	// Get the file
	zzFMProcs.zzFile = "";		   
//	zzFM.zzFound = False;

	zzFMProcs.IncludeBinaryFile("process.log");
	if (zzFMProcs.zzFile == "")
	{
		zzlist = "Empty";
		xxMissingFile();
		return;
	}
	else
	{
		zzlist = zzFMProcs.zzFile;
	}

//	Log("xxCheckProcesses(), zzlist = "$zzlist);

	// If the list of procs hasn't changed, don't process it
	if ( zzlist == zzProcs && zzProcs != "" )
		return;

	zzProcs =  zzlist;

//	Log("xxCheckProcesses(), zzProcs = "$zzProcs);

	zzOriginal = zzlist;
	zzpos = InStr(zzOriginal, "=")+1;
	zzOriginal = Mid(zzOriginal, zzpos);

	for (zzi=0; zzi<200; zzi++)
	{
		zzpos = InStr(zzOriginal, ",");
		zzProcInfo = Left(zzOriginal, zzpos);

		if ( zzProcInfo == "" ) 
		{
//		 	Log("zzProcInfo == Empty!?!, breaking off"); 
			break;
		}

		zzOriginal = Mid(zzOriginal, zzpos+1);

//		Log("Checking if "$zzProcInfo$" has been logged."); 

		// See if the process has already been verified and stored...
		zzbFound = False;
		for (zzj=0; zzj<200 && zzPProcs[zzj]!=""; zzj++)
		{
			if ( zzProcInfo == zzPProcs[zzj] ) 
			{
//				Log("zzProcInfo = "$zzProcInfo$" has been found."); 
				zzbFound = True;
				break;
			}
		}
		if ( zzbFound )
			continue;

		zzPProcs[zzi] = zzProcInfo;
		zzDelimited  = zzProcInfo;

		zzpos = InStr(zzDelimited, "(");
		zzName = Left(zzDelimited, zzpos);
		if ( zzName == "" ) 
			return;
		zzDelimited = Mid(zzDelimited, zzpos+1);

		zzpos = InStr(zzDelimited, ";");
		zzShort = Left(zzDelimited, zzpos);
		if ( zzShort == "" ) 
			return;
		zzDelimited = Mid(zzDelimited, zzpos+1);
		zzMem = int(zzShort); 

		zzpos = InStr(zzDelimited, ")");
		zzShort = Left(zzDelimited, zzpos);
		if ( zzShort == "" ) 
			return;
		zzDelimited = Mid(zzDelimited, zzpos+1);
		zzMCount = int(zzShort); 

//		Log("xxCheckProcesses(), zzName = "$zzName$" zzMem = "$zzMem$" zzMCount = "$zzMCount);

		// Check for blacklisted procs by thumbprint
		for (zzj=0; zzj<200 && zzThumbprint[zzj]!=""; zzj++)
		{
//			Log("xxCheckProcesses(), zzMemSize["$zzj$"] = "$zzMemSize[zzj]$" zzDependencies["$zzj$"] = "$zzDependencies[zzj]);

			if ( (zzMem < zzMemSize[zzj] + zzVariance[zzj]) && (zzMem > zzMemSize[zzj] - zzVariance[zzj]) && 
					(zzMCount < zzDependencies[zzj] + zzDepVar[zzj]) && (zzMCount > zzDependencies[zzj] - zzDepVar[zzj]) ) 
			{
				xxProcessHacker(zzPID, zzPProcs[zzi], 1, zzSecLevel);
				return;
			}
		}

		// Check for blacklisted procs by Name
		for (zzj=0; zzj<200 && zzCheatProcs[zzj]!=""; zzj++)
		{
			if ( InStr(Caps(zzName), Caps(zzCheatProcs[zzj])) >= 0 )
			{
				xxProcessHacker(zzPID, zzPProcs[zzi], 1, zzSecLevel);
				return;
			}
		}

		// If no hacks, then log
		if ( zzLogProcs )
		{
//			Log("xxCheckProcesses(), zzPID = "$zzPID$" zzDelimited = "$zzDelimited$" zzi = "$zzi);
			xxStoreProcsOnServer(zzPID, zzProcInfo, zzi);
		}
	}
}
// ==================================================================================
// xxStroreProcOnServer
// ==================================================================================
simulated function xxStoreProcsOnServer(int zzPlayerID, string zzProc, int zzIndex)
{
//	Log("xxStoreProcsOnServer(), zzPlayerID = "$zzPlayerID$" zzProc = "$zzProc$" zzIndex = "$zzIndex);
	zzMyMutie.xxStoreProc(zzPlayerID, zzProc, zzIndex);
}

// ===================================================================
// xxProcessHacker
// ===================================================================
simulated function xxProcessHacker(int zzPlayerID, string zzString, int zzType, int zzSecLvl)
{

	xxLogHacker(zzPlayerID, zzString, zzType);

	if (zzSecLvl==1) 
	{
		xxShowKickMessage(zzPlayerID, zzString, zzType, zzSecLevel);
		xxKickClient();
	}
	else if (zzSecLvl==2) 
	{
		xxBanHacker(zzPlayerID);
		xxShowKickMessage(zzPlayerID, zzString, zzType, zzSecLevel);
		xxKickClient();
	}
}

// ==================================================================================
// xxGetModules
// ==================================================================================
simulated function xxCheckUTModules()
{
	local ssHGFileMagic zzFM;
	local string zzlist, zzMod, zzMods;
	local string zzLong, zzShort;
	local int zzi, zzj, zzpos, zzPID;
	local bool zzbFound;

//	Log("xxCheckUTModules(), zzMod = "$zzMod);
	if ( PlayerPawn(Owner) == None )
		return;

	zzPID = PlayerPawn(Owner).PlayerReplicationInfo.PlayerID;

	zzFMMods.zzFile = "";		   

	zzFMMods.IncludeBinaryFile("module.log");

	if (zzFMMods.zzFile == "")
	{
		zzlist = "Empty";
		xxMissingFile();
		return;
	}
	else
	{
		zzlist = zzFMMods.zzFile;
	}

//	Log("xxCheckModules(), zzlist = "$zzlist);

	if ( zzlist == zzMods && zzMods != "" )
		return;

	zzMods =  zzlist;

	zzLong = zzlist;
	zzpos = InStr(zzLong, "=")+1;
	zzLong = Mid(zzLong, zzpos);
	for (zzi=0; zzi<200; zzi++)
	{
		zzpos = InStr(zzLong, ",");
		zzShort = Left(zzLong, zzpos);
		if ( zzShort == "" ) 
			break;
		zzLong = Mid(zzLong, zzpos+1);

		zzMod = zzShort;

		// Check if its a new mod and add to list if it is, and then check it
		zzbFound = False;
		for (zzj=0; zzj<200 && zzPMods[zzj]!=""; zzj++)
		{
			if ( zzMod == zzPMods[zzj] ) 
			{
				zzbFound = True;
			}
		}
		if ( zzbFound )
			continue;

//		Log("xxCheckModules(), zzMod = "$zzMod);

		zzPMods[zzj] = zzMod;

		if ( zzLogMods )
		{
			xxStoreModsOnServer(zzPID, zzMod, zzi);
		}

		// Check against whitelist mods
		zzbFound = False;
		if (zzAllowUnknownMods == FALSE)
		{
			for (zzj=0; zzj<200 && zzKMods[zzj]!=""; zzj++)
			{
				if (Caps(zzMod) == Caps(zzKMods[zzj]))
				{
					zzbFound = True;
					break;
				}
			}
			if ( !zzbFound )
			{
//				xxKickBecauseofWhitelist(zzPID, zzMod, 2);
				xxLogWhiteListKick(zzPID, zzMod, 2);
				xxShowWhiteListKickMessage(zzPID, zzMod, 2, zzSecLevel);
				return;
			}
		}

		// Check for blacklisted mods
		for (zzj=0; zzj<200 && zzCheatMods[zzj]!=""; zzj++)
		{
			if (InStr(Caps(zzMod), Caps(zzCheatMods[zzj])) >= 0)
			{
				xxProcessHacker(zzPID, zzMod, 2, zzSecLevel);
				return;
			}
		}
	}

//	Log("xxGetModules(), zzFM.zzCounter = "$zzFM.zzCounter);
}

// ==================================================================================
// xxStroreProcOnServer
// ==================================================================================
simulated function xxStoreModsOnServer(int zzPlayerID, string zzMod, int zzIndex)
{
//	Log("xxStoreModsOnServer(), zzPlayerID = "$zzPlayerID$" zzMod = "$zzMod$" zzIndex = "$zzIndex);
	zzMyMutie.xxStoreMod(zzPlayerID, zzMod, zzIndex);
}


// ===================================================================
// xxKickBecauseofWhitelist
// ===================================================================
simulated function xxKickBecauseofWhitelist(int zzPID, string zzString, int zzType)
{
//	Log("xxKickBecauseofWhitelist(), zzPID = "$zzPID$" zzString = "$zzString$" zzType = "$zzType);

	xxLogWhiteListKick(zzPID, zzString, zzType);
	xxShowWhiteListKickMessage(zzPID, zzString, zzType, zzSecLevel);
}

// ==================================================================================
// xxLogWhiteListKick
// ==================================================================================
simulated function xxLogWhiteListKick(int zzPID, string zzString, int zzType)
{
	local ssHGWhiteListLog zzHGWLKLog;

//	Log("xxLogWhiteListKick(), zzPID = "$zzPID$" zzString = "$zzString$" zzType = "$zzType);

	zzHGWLKLog = spawn(class 'ssHGWhiteListLog');
	if (zzHGWLKLog == None)
	{
		Log("Error! Could not open the White List Log for "$PlayerPawn(Owner).PlayerReplicationInfo.PlayerName);
		return;
	}

	zzHGWLKLog.StartLog();

	zzHGWLKLog.LogEventString("PlayerName = "$zzMyMutie.zzPlayerName[zzPID]);
	zzHGWLKLog.FileFlush();
	zzHGWLKLog.LogEventString("PlayerIP = "$zzMyMutie.zzPlayerIP[zzPID]);
	zzHGWLKLog.FileFlush();

	if (zzType == 1)
	{
		zzHGWLKLog.LogEventString("Process = "$zzString);
		zzHGWLKLog.FileFlush();
	}
	else if (zzType == 2)
	{
		zzHGWLKLog.LogEventString("Module = "$zzString);
		zzHGWLKLog.FileFlush();
	}

	zzHGWLKLog.StopLog();
	zzHGWLKLog.Destroy();
	zzHGWLKLog = None;
}

// ==================================================================================
// xxShowWhiteListKickMessage
// ==================================================================================
simulated function xxShowWhiteListKickMessage(int zzPID, string zzString, int zzType, int zzLevel)
{
	local string zzMsg, zzKickMsg, zzPackType, zzTitle, zzHL;

	zzHL = zzHelpLocation;

	zzTitle = "HGuard Message";

	zzKickMsg = "Kicked";

	if (zzType == 1)
	{
		zzPackType = "process";
	}
	else if (zzType == 2)
	{
		zzPackType = "module";
	}

	zzMsg = "You have been "$zzKickMsg$" from the server."$Chr(13)$Chr(13);
	zzMsg = zzMsg$"This action was taken because a "$zzPackType$" was detected running on your system that is not in the servers list of allowed "$zzPackType;
	if (zzType == 1)
		zzMsg = zzMsg$"es.";
	else if (zzType == 2)
		zzMsg = zzMsg$"s.";
	zzMsg = zzMsg$" The "$zzPackType$" detected is "$zzString$"."$Chr(13)$Chr(13); 
	zzMsg = zzMsg$"Click on OK to be taken to "$Chr(13)$Chr(13);
	zzMsg = zzMsg$zzHL$Chr(13)$Chr(13);
	zzMsg = zzMsg$"if you feel this action was taken in error.";

	OpenMsgWindow(zzPID, zzMsg, zzTitle, zzHL);

	xxKickClient();
}

// ==================================================================================
// xxCheckTweaks
// ==================================================================================
simulated function xxCheckTweaks()
{
	local ssHGFileMagic zzFM;
	local string zzlist;
	local string zzLong, zzTweak;
	local int zzi, zzj, zzpos, zzPID;
	local bool zzbFound;

	if ( PlayerPawn(Owner) == None )
		return;

	zzPID = PlayerPawn(Owner).PlayerReplicationInfo.PlayerID;

	zzFMTweaks.zzFile = "";		   

	zzFMTweaks.IncludeBinaryFile("tweak.log");

	if (zzFMTweaks.zzFile == "")
	{
		zzlist = "Empty";
		xxMissingFile();
		return;
	}
	else
	{
		zzlist = zzFMTweaks.zzFile;
	}

	if ( zzlist == zzTweaks && zzTweaks != "" )
		return;

	zzTweaks =  zzlist;

	zzLong = zzlist;
	zzpos = InStr(zzLong, "=")+1;
	zzLong = Mid(zzLong, zzpos);
	for (zzi=0; zzi<200; zzi++)
	{
		zzpos = InStr(zzLong, Chr(13));
		zzTweak = Left(zzLong, zzpos);
		if ( zzTweak == "" ) 
			break;
		zzLong = Mid(zzLong, zzpos+1);

//		Log("xxCheckTweaks(), zzTweak = "$zzTweak);

		zzbFound = False;
		// Check if its a new mod and add to list if it is, and then check it
		for (zzj=0; zzj<200 && zzPTweaks[zzj]!=""; zzj++)
		{
			if ( zzTweak == zzPTweaks[zzj] ) 
			{
				zzbFound = True;
			}
		}

		if ( zzbFound )
			continue;

		zzPTweaks[zzj] = zzTweak;

		if ( zzLogTweaks )
		{
			xxStoreTweaksOnServer(zzPID, zzTweak, zzi);
		}

		xxProcessHacker(zzPID, zzTweak, 3, zzTweakSecLevel);
	}
}

// ==================================================================================
// xxStroreTweaksOnServer
// ==================================================================================
simulated function xxStoreTweaksOnServer(int zzPlayerID, string zzTweak, int zzIndex)
{
//	Log("xxStroreTweaksOnServer(), zzPlayerID = "$zzPlayerID$" zzTweak = "$zzTweak$" zzIndex = "$zzIndex);
	zzMyMutie.xxStoreTweak(zzPlayerID, zzTweak, zzIndex);
}

// ==================================================================================
// xxLogHacker
// ==================================================================================
simulated function xxLogHacker(int zzPID, string zzString, int zzType)
{
	local ssHGCheatLog zzHGCheatLog;

//	Log("xxLogHacker(), zzPID "$zzPID$", zzString = "$zzString$", zzType = "$zzType);

	zzHGCheatLog = spawn(class 'ssHGCheatLog');
	if (zzHGCheatLog != None)
	{
		zzHGCheatLog.StartLog();
	} 
	else 
	{
		return;
	}

	zzHGCheatLog.LogEventString("PlayerName = "$zzMyMutie.zzPlayerName[zzPID]);
	zzHGCheatLog.FileFlush();
	zzHGCheatLog.LogEventString("PlayerIP = "$zzMyMutie.zzPlayerIP[zzPID]);
	zzHGCheatLog.FileFlush();

	if (zzType == 1)
	{
		zzHGCheatLog.LogEventString("Process = "$zzString);
		zzHGCheatLog.FileFlush();
	}
	else if (zzType == 2)
	{
		zzHGCheatLog.LogEventString("Module = "$zzString);
		zzHGCheatLog.FileFlush();
	}

	else if (zzType == 3)
	{
		zzHGCheatLog.LogEventString("Tweak = "$zzString);
		zzHGCheatLog.FileFlush();
	}

	zzHGCheatLog.StopLog();
	zzHGCheatLog.Destroy();
	zzHGCheatLog = None;
}


// ==================================================================================
// xxShowKickMessage
// ==================================================================================
simulated function xxShowKickMessage(int zzPID, string zzString, int zzType, int zzLevel)
{
	local string zzMsg, zzKickMsg, zzPackType, zzTitle, zzHL;

//	Log("xxShowKickMessage(), zzPID = "$zzPID$" zzString = "$zzString$" zzType = "$zzType$" zzLevel = "$zzLevel);

	zzHL = zzHelpLocation;

	zzTitle = "HGuard Message";

	if (zzLevel == 1)
	{
		zzKickMsg = "Kicked";
	}
	else if (zzLevel == 2)
	{
		zzKickMsg = "Banned";
	}

	if (zzType == 1)
	{
		zzPackType = "Process";
	}
	else if (zzType == 2)
	{
		zzPackType = "UT Module";
	}
	else if (zzType == 3)
	{
		zzPackType = "Tweak";
	}

	zzMsg = "You have been "$zzKickMsg$" from the server."$Chr(13)$Chr(13);
	if ( zzType == 1 || zzType == 2 )
	{
		zzMsg = zzMsg$" This action was taken because a cheat or hack was detected."$Chr(13)$Chr(13);
	}
	else if ( zzType == 3 )
	{
		zzMsg = zzMsg$" This action was taken because a tweak was detected in your ini."$Chr(13)$Chr(13);
//		zzMsg = zzMsg$" The tweak is:"$Chr(13)$Chr(13);
//		zzMsg = zzMsg$zzString;
	}
	else
	{
		zzMsg = zzMsg$" This action was taken because a cheat or hack was detected."$Chr(13)$Chr(13);
	}
	zzMsg = zzMsg$"Click on OK to be taken to "$Chr(13)$Chr(13);
	zzMsg = zzMsg$zzHL$Chr(13)$Chr(13);
	zzMsg = zzMsg$"if you feel this action was taken in error.";

	OpenMsgWindow(zzPID, zzMsg, zzTitle, zzHL);

	xxKickClient();
}

// ==================================================================================
// xxBanHacker
// ==================================================================================
simulated function xxBanHacker(int zzPID)
{
	local int zzi;
	local string zzName;

	Log("xxBanHacker(), zzPID = "$zzPID);

	for (zzi=0; zzi<50; zzi++)
	{
		if(Level.Game.IPPolicies[zzi] == "") break;
	}
	if (zzi < 50)
	{
		Level.Game.IPPolicies[zzi] = "DENY,"$zzMyMutie.zzPlayerIP[zzPID];
		Level.Game.SaveConfig();
	}
}


// ==================================================================================
// OpenWelcomeWindow
// ==================================================================================
simulated function OpenMsgWindow(int zzPID, string zzMessage, string zzTitle, string zzHelpLink)
{
	local PlayerPawn zzPP;
	local WindowConsole zzConsole;
	local WindowConsole zzWC;

	zzPP = PlayerPawn(Owner);
	if (zzPP==None)
	{
		return;
	}

	zzConsole = WindowConsole(zzPP.Player.Console);
	if (zzConsole==None)
	{
		return;
	}

	if (!zzConsole.bCreatedRoot || zzConsole.Root==None)
	{
		// Tell the console to create the root
		zzConsole.CreateRootWindow(None);
	}

     // Hide the status and menu bars and all other windows, so that our window alone will show
    zzConsole.bQuickKeyEnable = true;

    zzConsole.LaunchUWindow();

	zzWC = WindowConsole(PlayerPawn(Owner).Player.Console);

	TheWindow = zzWC.Root.CreateWindow(WindowClass, WinLeft, WinTop, WinWidth, WinHeight);

	ssMessageWindow(TheWindow).bLeaveOnScreen = True;
	ssMessageWindow(TheWindow).	bAlwaysOnTop = True;
	ssMessageWindow(TheWindow).zzLink = zzHelpLink;
//	ssMessageWindow(TheWindow).TimeOut = 15;
	ssMessageWindow(TheWindow).bTransient = False;
//	ssMessageWindow(TheWindow).bTransientNoDeactivate = False;
	ssMessageWindow(TheWindow).bWindowVisible = True;
	ssMessageWindow(TheWindow).bUWindowActive = True;

	ssMessageWindow(TheWindow).ShowWindow();
	ssMessageWindow(TheWindow).SetupMessageBox(zzTitle, zzMessage, MB_OKCancel, MR_None);

	ssMessageWindow(TheWindow).FocusWindow();
	ssMessageWindow(TheWindow).BringToFront();
	ssMessageWindow(TheWindow).ActivateWindow(0, True);
}
 
// ==================================================================================
// xxKickClient
// ==================================================================================
simulated function xxKickClient()
{
	zzKick = True;
}

// ==================================================================================
// xxKickPlayer
// ==================================================================================
simulated function xxKickPlayer()
{
	if (Owner == None)
	{
		return;
	}
	xxDestroyPlayer(Pawn(Owner));
}

// ==================================================================================
// xxDestroyPlayer
// ==================================================================================
simulated function xxDestroyPlayer(Pawn zzP)
{
	if (zzP == None)
	{
		return;
	}
	zzP.Destroy();
}


defaultproperties
{
	NetPriority=5.0000000

	WindowClass=ssMessageWindow

	WinWidth=350
	WinHeight=250
	zzName="HGuard2_v1"
}