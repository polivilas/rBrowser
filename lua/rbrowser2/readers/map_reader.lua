--[[
	File Browser 2.0
	by Ryan 'Joudoki' Lewellen
	June 9th, 2008 - June 24th, 2008
--]]

-- For reading text or lua files
mapChanger = {};
mapChanger.Readers = {};

function mapChanger.Create( fData )
	if ( !fData ) then
		return false end
		
	local path = string.gsub( fData.path .. fData.name, "../maps/", "" );
	print( "Opening mapchange question: [" .. path .. "]" );
		
	local id = table.getn( mapChanger.Readers ) + 1;
	local reader = vgui.Create( "DFrame" );
		reader:SetSize( 300,150 );
		reader:SetPos( 50,50 );
		reader:SetTitle( tostring( fData.name ) .. "." .. tostring( fData.ext ));
		reader:SetVisible( true );
		reader:SetDraggable( true );
		reader:ShowCloseButton( true );
		reader:MakePopup();
	
	local contents = vgui.Create( "DPanelList", reader );
		contents:SetPos( 10, 30 );
		contents:SetSize( 280, 110 );
		contents:SetPadding( 4 );
		contents:SetSpacing( 10 );
		
	local label = vgui.Create( "DLabel", reader );
		label:SetText( "Would you like to change the map to [" .. fData.name .. "]?" );
		label:SizeToContents();		
		
	local warning = vgui.Create( "DLabel", reader );
		warning:SetText( "WARNING: You will be disconnected from the server." );
		warning:SizeToContents();
		
	local yes = vgui.Create( "DButton", reader );
		yes:SetText( "Yes" );
		yes.DoClick = function() print( "Changing map! [" .. path .. "]" ); RunConsoleCommand( "map", path ); end
		
	local cancel = vgui.Create( "DButton", reader );
		cancel:SetText( "Cancel" );
		cancel.DoClick = function() reader:Close() end;
	
	contents:AddItem( label );
	contents:AddItem( warning );
	contents:AddItem( yes );
	contents:AddItem( cancel );
	
	reader.contents = contents;
	reader.label = label;
	reader.warning = label;
	reader.yes = label;
	reader.cancel = label;	
	
	mapChanger.Readers[id] = reader;
	return id;
	
end
function mapChanger.Remove( ID )
	if ( mapChanger.Readers[ ID ] ) then
		mapChanger.Readers[ ID ]:Remove();
	end
end