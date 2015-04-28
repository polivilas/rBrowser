--[[
	File Browser 2.0
	by Ryan 'Joudoki' Lewellen
	June 9th, 2008 - June 24th, 2008
--]]

if ( fileBrowser ) then
	if ( fileBrowser.window ) then
		fileBrowser.window:Remove();
	end
	if ( fileBrowser.Settings and fileBrowser.Settings.window ) then
		fileBrowser.Settings.window:Remove();
	end
end

fileBrowser = {};

-- Raw file I/O
include( "rbrowser2/cl_filelib.lua" );

-- Controls
include( "rbrowser2/vgui/DSizeGrip.lua" );
include( "rbrowser2/vgui/DSizeableFrame.lua" );
include( "rbrowser2/vgui/fileScrollerGrip.lua" );
include( "rbrowser2/vgui/fileHScroller.lua" );
include( "rbrowser2/vgui/fileVScroller.lua" );
include( "rbrowser2/vgui/fileViewer_TextArea.lua" );
include( "rbrowser2/vgui/fileViewer.lua" );
include( "rbrowser2/vgui/matView.lua" );
include( "rbrowser2/vgui/TextBoxHistory.lua" );
include( "rbrowser2/vgui/MessageBox.lua" );

-- Main GUIs
include( "rbrowser2/cl_settings.lua" );

-- File Viewer GUIs
include( "rbrowser2/readers/text_reader.lua" );
include( "rbrowser2/readers/sound_reader.lua" );
include( "rbrowser2/readers/mat_reader.lua" );
include( "rbrowser2/readers/map_reader.lua" );
include( "rbrowser2/readers/html_reader.lua" );
include( "rbrowser2/readers/image_viewer.lua" );

-- Properties GUI
include( "rbrowser2/readers/properties_reader.lua" );

-- Browser GUI
include( "rbrowser2/cl_browser.lua" );

-- Find GUI
include( "rbrowser2/cl_find.lua" );

-- Console Commands
include( "rbrowser2/cl_console.lua" );

function browser_init()
	fileBrowser.Settings.Load();

	fileBrowser.Create();
	fileBrowser.Settings.Create();
	fileBrowser.Find.Create();
	
	textReader.MakeSettingsPanel()
	soundPlayer.MakeSettingsPanel();
	matViewer.MakeSettingsPanel()
end
 hook.Add( "Initialize", "rBrowser_Init", browser_init );  