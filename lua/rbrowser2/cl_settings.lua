--[[
	File Browser 2.0
	by Ryan 'Joudoki' Lewellen
	June 9th, 2008 - June 24th, 2008
--]]

if ( !fileBrowser ) then error( "fileBrowser core not found! Error in cl_browser.lua or missing!" ) end
if ( fileBrowser.Settings ) then
	if ( fileBrowser.Settings.window ) then
		fileBrowser.Settings.window:Remove();
	end
end

fileBrowser.sounds = {};
fileBrowser.sounds[ "file_open" ] = "common/bugreporter_succeeded.wav";
fileBrowser.sounds[ "reader_open" ] = false;
fileBrowser.sounds[ "reader_close" ] = false;
fileBrowser.sounds[ "browser_open" ] = false;
fileBrowser.sounds[ "browser_close" ] = false;

function fileBrowser.AddExtension( eExt, eName, eAction, eMaterial )
	exts[ eExt ] = { name=eName, action=eAction, material=eMaterial };
end

fileBrowser.Settings = {};
fileBrowser.Settings.window = nil;
fileBrowser.Settings.sheets = {};

fileBrowser.Settings.SaveLoc = "rBrowser.txt";

fileBrowser.Settings.Data = {};
fileBrowser.Settings.Data[ "playsounds"] = "true";
fileBrowser.Settings.Data[ "sounds" ] = {};
fileBrowser.Settings.Data[ "sounds" ][ "file_open" ] = "common/bugreporter_succeeded.wav";
fileBrowser.Settings.Data[ "sounds" ][ "reader_open" ] = "false";
fileBrowser.Settings.Data[ "sounds" ][ "reader_close" ] = "false";
fileBrowser.Settings.Data[ "sounds" ][ "browser_open" ] = "false";
fileBrowser.Settings.Data[ "sounds" ][ "browser_close" ] = "false";
fileBrowser.Settings.Data[ "openlastdir" ] = "false";
fileBrowser.Settings.Data[ "lastdir" ] = "";

function fileBrowser.Settings.GetSetting( val )
	if ( fileBrowser.Settings.Data[val] ) then
		if ( fileBrowser.Settings.Data[val] == "true" or fileBrowser.Settings.Data[val] == "false" ) then
			return tobool( fileBrowser.Settings.Data[val] );
		end
		return fileBrowser.Settings.Data[val];
	else
		print( "Invalid data request - " .. val );
		return nil;
	end
end

function fileBrowser.Settings.SetSetting( val, set )
	fileBrowser.Settings.Data[ val ] = tostring( set );
end

function fileBrowser.Settings.Save()
	print( "Saving rBrowser Settings" );
	local data = util.TableToKeyValues( fileBrowser.Settings.Data );
	file.Write( fileBrowser.Settings.SaveLoc, data );
end

function fileBrowser.Settings.Load()
	if ( file.Exists( fileBrowser.Settings.SaveLoc,"DATA" ) == true  ) then
		print( "Loading rBrowser Settings" );
		local data = file.Read( fileBrowser.Settings.SaveLoc );
		if ( ! file ) then return false end
		fileBrowser.Settings.Data = util.KeyValuesToTable( data );
	end
end

function fileBrowser.Settings.Create()
	if ( fileBrowser.Settings.window ) then fileBrowser.Settings.window:Remove() end
	local settings = vgui.Create( "DFrame" );
		settings:SetPos( 10, 10 )
		settings:SetSize( 600, 400 );
		settings:SetTitle( "Resource Browser  - Settings" );
		settings:SetDraggable( true );
		settings:ShowCloseButton( true );
		settings:SetDeleteOnClose( false );
		settings:SetVisible( false );
		settings.btnClose.DoClick = function()
			settings:Close();
			fileBrowser.Settings.Save();
		end
		
	local pSheet = vgui.Create( "DPropertySheet", settings );
		pSheet:SetPos( 10,30 );
		pSheet:SetSize( 580, 360 );

		fileBrowser.Settings.window = settings;
		fileBrowser.Settings.window.pSheet = pSheet;

	-- General Options
	local settings = fileBrowser.Settings.AddSheet( "General", "rbrowser/folder.vmt", "General Settings" );
	fileBrowser.Settings.AddOption( settings, "checkbox", "Enable Sounds",  "enablesounds", true );
	fileBrowser.Settings.AddOption( settings, "checkbox", "Open last open directory on open", "openlastdir", false );
end

function fileBrowser.Settings.AddSheet( name, mat, tooltip )
	local settings = vgui.Create( "DPanelList", fileBrowser.Settings.window );
		settings:SetSpacing( 5 );
		settings:SetPadding( 10 );
		settings:EnableHorizontal( false );
		settings:EnableVerticalScrollbar( true );
	fileBrowser.Settings.window.pSheet:AddSheet( name, settings, mat, false, false, tooltip );
	return settings;
end
function fileBrowser.Settings.AddOption( settings, type, label, optionName, defaultValue )
	local newSetting = nil;
	if ( type == "checkbox" ) then
		newSetting = vgui.Create( "DCheckBoxLabel", settings );
			newSetting:SetText( label );
			newSetting:SetValue( defaultValue );
			newSetting:SizeToContents();
			newSetting.OnChange = function( b ) 
				if not ( fileBrowser.Settings.Data[ optionName ] ) then
					fileBrowser.Settings.Data[ optionName ] = b;
				end
			end
			settings:AddItem( newSetting );
		fileBrowser.Settings.SetSetting( optionName, defaultValue );
	else
		
	end
	
	return newSetting;
end

hook.Add( "Initialize", "fileBrowser.Settings.Load", fileBrowser.Settings.Load ); 
hook.Add( "ShutDown", "fileBrowser.Settings.Save", fileBrowser.Settings.Save ); 