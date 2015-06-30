#include <sourcemod>

#define PLUGIN_VERSION "1.0"

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
	RegConsoleCmd("sm_songs",Menu_Test1,"[rA] Open Song List Menu");
	RegConsoleCmd("sm_songlist",Menu_Test1,"[rA] Open Song List Menu");
	RegConsoleCmd("sm_scmd",Menu_Test1,"[rA] Open Song List Menu");
	RegConsoleCmd("sm_songmenu",Menu_Test1,"[rA] Open Song List Menu");
	
	g_Shortcuts = CreateArray( 64 );
	g_Titles = CreateArray( 64 );
	g_Links = CreateArray( 512 );
	
	LoadSongList();
}

public MenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	switch(action)
	{ 
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
			
				if (StrEqual(titles, info) )
					{
						StreamPanel(titles,links,param1);	
						break;
					} 
						
			}
		} 
		case MenuAction_End:
		{
			CloseHandle(menu);
		} 
	}
 
	return 0;
}
 
public Action:Menu_Test1(client, args)
{
	new Handle:menu = CreateMenu(MenuHandler1);
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
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
 
	return Plugin_Handled;
}

public StreamPanel( String:title[],String:url[], client) {

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

