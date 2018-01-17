#define FILTERSCRIPT //ACCESSIBLE IN GAME DATABASE + MULTIACCOUNTERS DETECTOR BY RogueDrifter
#include <a_samp>
#include <dini>
#include <dutils>
#include <zcmd>
#define Database "Database/%s.ini"
#define COLOR_DARKRED 0xAA3333AA
#define COLOR_LIGHTGREEN 0xFF0000A

new plName[MAX_PLAYER_NAME],nfile[64],plIP[26],plVers[10],FullDate[100],plHWID[80],OtherString[126];

native gpci(playerid, serial[], len);

public OnPlayerConnect(playerid)
{
    GetPlayerName(playerid,plName,sizeof(plName));
    gpci(playerid,plHWID,sizeof(plHWID));
    GetPlayerIp(playerid,plIP,sizeof(plIP));
    GetPlayerVersion(playerid,plVers,sizeof(plVers));
    format(plName,sizeof(plName),"%s",strlower(plName));
    format(nfile,sizeof(nfile),Database,plName);
    if(!fexist(nfile))
    {
        dini_Create(nfile);
        dini_Set(nfile,"hwID",plHWID );
        dini_Set(nfile,"pIP", plIP);
        dini_Set(nfile,"cIP", plIP);
        dini_Set(nfile,"cHWID", plHWID);
        dini_Set(nfile,"Version", plVers); // setting the player's original data
        if(strlen(dini_Get("MultiAccountersBase/haka.txt", plHWID)) == 0)
        { //that id wasn't registered before (getting into the also known as system)
            dini_Set("MultiAccountersBase/haka.txt", plHWID, plName);
            }//create it
        else if(strfind( dini_Get("MultiAccountersBase/haka.txt", plHWID), plName, true) == -1 )
        { //it was registered before, so lets add that player's name next to the others using it.
            format(OtherString,sizeof(OtherString),"%s,%s", dini_Get("MultiAccountersBase/haka.txt",plHWID), plName);
            dini_Set("MultiAccountersBase/haka.txt", plHWID, OtherString);
            }
        if(strlen(dini_Get("MultiAccountersBase/aka.txt", plIP)) == 0)
        {
            dini_Set("MultiAccountersBase/aka.txt", plIP, plName);//if its a new ip
            }
        else if(strfind( dini_Get("MultiAccountersBase/aka.txt", plIP), plName, true) == -1 )
             { //it was here before, lets put this player's name next to the others ( this is very accurate if u get a match here, its a multiaccounter.
                format(OtherString,sizeof(OtherString),"%s,%s", dini_Get("MultiAccountersBase/aka.txt",plIP), plName);
                dini_Set("MultiAccountersBase/aka.txt", plIP, OtherString);
                }
            }
        else
        {
            dini_Set(nfile,"cIP",plIP );
            dini_Set(nfile,"cHWID", plHWID);
            } //record the data that could change indicating the player has a changing ip/hardwareid
    return 1;
}
public OnPlayerDisconnect(playerid,reason)
{ //here we will record the last date a player was on every time a player disconnects each in their own file.
    new pyear,pmonth,pday,phour,pminute,psecond;
    getdate(pyear,pmonth,pday);
    gettime(phour,pminute,psecond);
    format(FullDate,sizeof(FullDate),"Year:%d, Month:%d, Day:%d, Hour:%d, Minute:%d, Second:%d",pyear,pmonth,pday,phour,pminute,psecond);
    GetPlayerName(playerid,plName,sizeof(plName));
    format(plName,sizeof(plName),"%s",strlower(plName));
    format(nfile,sizeof(nfile),Database,plName);
    dini_Set(nfile,"LastOn",FullDate);
    return 1;
}
CMD:getpstats(playerid,params[])
{
            new pidx,ptmp[256],StatsString[1024];
            if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,-1,"UNAUTHORIZED CMD!");//based on rcon, change to ur admin system if you'll take it as a snippet

            ptmp = strtok(params,pidx);

            if(strlen(ptmp) <2) return SendClientMessage(playerid, COLOR_LIGHTGREEN, "USAGE: /getpstats [Name]");

            format(plName,sizeof(plName),"%s",strlower(ptmp)), format(nfile,sizeof(nfile),Database,plName);

            if(!dini_Exists(nfile)) return SendClientMessage(playerid,COLOR_DARKRED,".:PLAYER DOESNT EXIST:.");
            //down there formatting the string and using strcat to break it down and install it in the msgboxstyle dialogue.
            format(StatsString,sizeof(StatsString),"{CCCCCC}.: {99FF00}Stats For {FFFFFF}%s {CCCCCC}:.",StatsString);
            format(StatsString,sizeof(StatsString),"%s\n{FFFFFF}-------------");
            format(StatsString,sizeof(StatsString),"%s\n{CCCCCC}.: {99FF00}Player Hwid: {FFFFFF}%s {CCCCCC}:.",StatsString,dini_Get(nfile,"hwID"));//constant first used hwid
            format(StatsString,sizeof(StatsString),"%s\n{CCCCCC}.: {99FF00}Player IP: {FFFFFF}%s {CCCCCC}:.",StatsString,dini_Get(nfile,"pIP"));//constant first used ip
            format(StatsString,sizeof(StatsString),"%s\n{CCCCCC}.: {99FF00}Player cIP: {FFFFFF}%s {CCCCCC}:.",StatsString,dini_Get(nfile,"cIP"));//stands for on-going changing ip
            format(StatsString,sizeof(StatsString),"%s\n{CCCCCC}.: {99FF00}Player Version: {FFFFFF}%s {CCCCCC}:.",StatsString,dini_Get(nfile,"Version"));
            format(StatsString,sizeof(StatsString),"%s\n{CCCCCC}.: {99FF00}Player cHwid: {FFFFFF}%s {CCCCCC}:.",StatsString,dini_Get(nfile,"cHWID"));//stands for on-going changing hwid
            format(StatsString,sizeof(StatsString),"%s\n{CCCCCC}.: {99FF00}Player AKA IP: {FFFFFF}%s {CCCCCC}:.",StatsString,dini_Get("MultiAccountersBase/aka.txt",dini_Get(nfile,"pIP")));//multiaccounters ip wise
            format(StatsString,sizeof(StatsString),"%s\n{CCCCCC}.: {99FF00}Player AKA HWID: {FFFFFF}%s {CCCCCC}:.",StatsString,dini_Get("MultiAccountersBase/haka.txt",dini_Get(nfile,"hwID")));//multiaccounters hwid wise ( NOT ACCURATE )
            format(StatsString,sizeof(StatsString),"%s\n{CCCCCC}.: {99FF00}Player Last On: {FFFFFF}%s {CCCCCC}:.",StatsString,dini_Get(nfile,"LastOn"));//last time that player was on

            ShowPlayerDialog(playerid, 3647, DIALOG_STYLE_MSGBOX, "{CCCCCC}.: Database Stats :.",StatsString, "{CCCCCC}Okay", "");

            return 1;
}
