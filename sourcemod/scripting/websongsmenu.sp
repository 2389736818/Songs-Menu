#include <sourcemod>
//#include <webshortcuts_csgo>

#define PLUGIN_VERSION "1.0"

//new String:link[] = "\"https://www.youtube.com/watch?v=-QlqqhzLVFo\"";

public Plugin:myinfo =
{
	name = "Song Menu",
	author = "Cooki3",
	description = "Menu to play custom MOTD songs",
	version = PLUGIN_VERSION,
	url = "http://www.renegade.army/forums/"
};

new Handle:g_Shortcuts;
new Handle:g_Titles;
new Handle:g_Links;

public OnPluginStart()
{
	//LoadTranslations("menu_test.phrases");	
	RegConsoleCmd("sm_songs",Menu_Test1,"[rA] Open Song List Menu");
	RegConsoleCmd("sm_songlist",Menu_Test1,"[rA] Open Song List Menu");
	RegConsoleCmd("sm_scmd",Menu_Test1,"[rA] Open Song List Menu");
	RegConsoleCmd("sm_songmenu",Menu_Test1,"[rA] Open Song List Menu");
	
	//RegConsoleCmd("sm_gt",Get_authstring,"[rA] Get Your SteamId");
	//RegConsoleCmd("sm_gc",Get_clientID,"[rA] Get Your Id");
	
	g_Shortcuts = CreateArray( 64 );
	g_Titles = CreateArray( 64 );
	g_Links = CreateArray( 512 );
	
	LoadSongList();
}
public Action:Get_authstring(client, args)
{
decl String:auth[64];
GetClientAuthString(client,auth,sizeof(auth));
PrintToChatAll("AuthString: %s",auth);
}
public Action:Get_clientID(client, args)
{
PrintToChatAll("ClientID: %i",client)
}
//public Action:Web_Song_Cmds(client, args)
//{
//	CmdPanel(client);
//	return Plugin_Handled;
//}



public MenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	//decl String:text[512] = "https://listenonrepeat.com/?v=UUBAFPIHETA#Jai_Paul_-_BTSTU_(Edit)";
	switch(action)
	{
		case MenuAction_Start:
		{
			PrintToServer("Displaying menu");
		}
 
		case MenuAction_Display:
		{
		
		}
 
		case MenuAction_Select:
		{
			decl String:info[64];
			GetMenuItem(menu, param2, info, sizeof(info));
			new size = GetArraySize( g_Shortcuts );
						
			for (new i; i != size; ++i)
			{
			decl String:titles [64];
			decl String:links [512];
			GetArrayString( g_Titles, i, titles, sizeof(titles) );
			GetArrayString( g_Links, i, links, sizeof(links) );
			
			//PrintToChatAll(" %d: selected %s", i, titles);
			//PrintToChatAll(" %d: selected %s", i, info);
			if (StrEqual(titles, info) )
			{
				StreamPanel(titles,links,param1);	
				break;
			} 
				//PrintToChatAll("Client %d selected %s", param1, info);
			
			
			
			}
					
			//if (StrEqual(info, CHOICE3))
			//{
			//	PrintToChatAll("Client %d somehow selected %s despite it being disabled", param1, info);
			//}
			//else
			//{
			//	PrintToChatAll("Client %d selected %s", param1, info);
			//}
			//switch(param2)
			//{
			//case 0:
			//		StreamPanel("songs",text,param1);								
			//
			//
			//
			////case 1:
			////PrintToChatAll("Client %d selected %s", param1, info);
			////case 2:
			////PrintToChatAll("Client %d selected %s", param1, info);			
			//}
		}
 
		case MenuAction_Cancel:
		{
			PrintToServer("Client %d's menu was cancelled for reason %d", param1, param2);
		}
 
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
 
		case MenuAction_DrawItem:
		{
			//new style;
			//decl String:info[64];
			//GetMenuItem(menu, param2, info, sizeof(info), style);
			//if (StrEqual(info, CHOICE3))
			//{
			//	return ITEMDRAW_DISABLED;
			//}
			//else
			//{
			//	return style;
			//}
		}
 
		case MenuAction_DisplayItem:
		{
			//decl String:info[64];
			//GetMenuItem(menu, param2, info, sizeof(info));
           //
			//decl String:display[64];
           //
			//if (StrEqual(info, CHOICE3))
			//{
			//	Format(display, sizeof(display), "%T", "Choice 3", param1);
			//	return RedrawMenuItem(display);
			//}
		}
	}
 
	return 0;
}
 
public Action:Menu_Test1(client, args)
{
	new Handle:menu = CreateMenu(MenuHandler1, MENU_ACTIONS_ALL);
	SetMenuTitle(menu, "rA Song Menu");
	new size = GetArraySize( g_Shortcuts );
	for (new i; i != size; ++i)
	{
	decl String:sname [64];
	decl String:title [64];
	GetArrayString( g_Shortcuts, i, sname, sizeof(sname) );
	GetArrayString( g_Titles, i, title, sizeof(title) );
	
	AddMenuItem(menu,title,sname);	
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 20000);
 
	return Plugin_Handled;
}

public StreamPanel( String:title[],String:url[], client) {
	//PrintToChatAll("%s",url);
	//PrintToChatAll("%s",title);
	new Handle:Radio = CreateKeyValues("data");
	KvSetString(Radio, "title", title);
	KvSetString(Radio, "type", "2");
	KvSetString(Radio, "msg", url);
	ShowVGUIPanel(client, "info", Radio, true);
	CloseHandle(Radio);
}

LoadSongList()
{
	decl String:buffer [1024];
	BuildPath( Path_SM, buffer, sizeof(buffer), "configs/songlist.txt" );
	
	if ( !FileExists( buffer ) )
	{
		return;
	}
 
	new Handle:f = OpenFile( buffer, "r" );
	if ( f == INVALID_HANDLE )
	{
		LogError( "[SM] Could not open file: %s", buffer );
		return;
	}
	
	ClearArray( g_Shortcuts );
	ClearArray( g_Titles );
	ClearArray( g_Links );
	
	decl String:shortcut [64];
	decl String:title [64];
	decl String:link [512];
	while ( !IsEndOfFile( f ) && ReadFileLine( f, buffer, sizeof(buffer) ) )
	{
		TrimString( buffer );
		if ( buffer[0] == '\0' || buffer[0] == ';' || ( buffer[0] == '/' && buffer[1] == '/' ) )
		{
			continue;
		}
		
		new pos = BreakString( buffer, shortcut, sizeof(shortcut) );
		if ( pos == -1 )
		{
			continue;
		}
		
		new linkPos = BreakString( buffer[pos], title, sizeof(title) );
		if ( linkPos == -1 )
		{
			continue;
		}
		
		strcopy( link, sizeof(link), buffer[linkPos+pos] );
		TrimString( link );
		
		PushArrayString( g_Shortcuts, shortcut );
		PushArrayString( g_Titles, title );
		PushArrayString( g_Links, link );
	}
	
	CloseHandle( f );
}









//public CmdPanel(client)
//{
//	new Handle:panel = CreatePanel();
//	decl String:title[64];
//	Format(title, 64, "KZ Timer Help (1/3) - v%s\nby 1NuTWunDeR",VERSION);
//	DrawPanelText(panel, title);
//	DrawPanelText(panel, " ");
//	DrawPanelText(panel, "!help - opens this menu");
//	DrawPanelText(panel, "!help2 - explanation of the ranking system");
//	DrawPanelText(panel, "!menu - checkpoint menu");
//	DrawPanelText(panel, "!options - player options menu");	
//	DrawPanelText(panel, "!top - top menu");
//	DrawPanelText(panel, "!latest - prints in console the last map records");
//	DrawPanelText(panel, "!profile/!ranks - opens your profile");
//	DrawPanelText(panel, "!checkpoint / !gocheck - checkpoint / gocheck");
//	DrawPanelText(panel, "!prev / !next - previous or next checkpoint");
//	DrawPanelText(panel, "!undo - undoes your last teleport");
//	DrawPanelText(panel, " ");
//	DrawPanelItem(panel, "next page");
//	DrawPanelItem(panel, "exit");
//	SendPanelToClient(panel, client, HelpPanelHandler, 5);
//	CloseHandle(panel);
//}
//
//public HelpPanelHandler(Handle:menu, MenuAction:action, param1, param2)
//{
//	if (action == MenuAction_Select)
//	{
//	}
//}
