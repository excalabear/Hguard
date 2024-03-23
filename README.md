# Hguard
Unreal Tournament V348 anticheat
HGuard was a WIP anticheat for dedicated unreal tournament demo V348 servers. It is a 2 part system Ubrowser.dll and Hguard.u. The dll is downloaded to the players local tournamntdemo\system folder manually by clicking a link that will show up when attempting to join the server and the player would have to move the file to the folder manually since a auto download function had not been implemented yet. Once the dll is placed the player may join the server and the other half of the anticheat that is on the server goes to work.


The dll looks for matching process fingerprints of know aimbots,wall hacks etc inside of unreal tournemnt.exe and hold on to the data until Hguard is ready to verify player. Hguard checks the players data from Ubrowser against a predefined list of cheats in HGuard.ini. More fingerprints can be added at will. If the player passes they may play if they fail they are logged to server and banned.
There are various setting in HGuard.ini that can be set and the frequency of check

There were some features I never got around to adding. Such as
Client side screen shot of there in game screen to see if any gui is present.
Auto dll Downloader and installer built in.
Anthrax made a great tool for his called nploader.