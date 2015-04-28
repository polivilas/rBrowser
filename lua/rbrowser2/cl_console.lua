--[[
	File Browser 2.0
	by Ryan 'Joudoki' Lewellen
	June 9th, 2008 - June 24th, 2008
--]]

function openBrowser( ply, cmd, args )
	if ( !fileBrowser) then return false end
	
	local folder = args[1] or "../";
	local filter = args[2] or "*";
	
	fileBrowser.window:SetVisible( true );
	fileBrowser.window:MakePopup();
	
	if ( fileBrowser.Restore == false ) then 
		fileBrowser.OpenFolder( folder, filter ) end
		
	fileBrowser.Restore = true;
end
concommand.Add( "browser_open", openBrowser );

function closeBrowser( ply, cmd, args )
	if ( !fileBrowser ) then return false end
	if ( !fileBrowser.window ) then return false end
	fileBrowser.window:SetVisible( false );
end
concommand.Add( "browser_close", closeBrowser );