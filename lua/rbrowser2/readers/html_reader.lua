--[[
	File Browser 2.0
	by Ryan 'Joudoki' Lewellen
	June 9th, 2008 - June 24th, 2008
--]]

-- For reading text or lua files
htmlReader = {};
htmlReader.Readers = {};

function htmlReader.Create( fData )
	if ( !fData ) then
		return false end

	print( "Opening text file in reader: [" .. fData.path .. fData.name .. "." .. fData.ext .. "]" );
		
	local id = table.getn( htmlReader.Readers ) + 1;
	local hReader = vgui.Create( "DFrame" );
		hReader:SetSize( 800,600 );
		hReader:SetPos( 50,50 );
		hReader:SetTitle( "[" .. tostring( fData.name ) .. "." .. tostring( fData.ext ) .. "] Resource Browser HTML Viewer" );
		hReader:SetVisible( true );
		hReader:SetDraggable( true );
		hReader:ShowCloseButton( true );
		hReader:MakePopup();
	local htmlView = vgui.Create( "HTML", hReader );
		htmlView:SetPos( 10,30 );
		htmlView:SetSize( 800-20, 600-40 );
		htmlView:SetHTML( file.Read( fData.path .. fData.name .. "." .. fData.ext ) );
		--htmlView:OpenURL( path ); 
		
	hReader.htmlView = htmlView;
	htmlReader.Readers[id] = hReader;
	return id;
	
end
function htmlReader.Remove( ID )
	if ( htmlReader.Readers[ ID ] ) then
		htmlReader.Readers[ ID ]:Remove();
	end
end

function htmlReader.MakeSettingsPanel()
	-- Settings
	local settings = vgui.Create( "Panel", fileBrowser.Settings.window );
	local horiz_bar_show = vgui.Create( "DCheckBoxLabel", settings );
	horiz_bar_show:SetPos( 10,10 );
	horiz_bar_show:SetSize( 200,20 );
	horiz_bar_show:SetText( "Always show horizontal scrollbar" );
	horiz_bar_show:SetValue( 1 );
	local wordwrap_default = vgui.Create( "DCheckBoxLabel", settings );
	wordwrap_default:SetPos( 10,40 );
	wordwrap_default:SetSize( 200,20 );
	wordwrap_default:SetText( "Wordwrap by default" );
	wordwrap_default:SetValue( 1 );
	local linenumbers = vgui.Create( "DCheckBoxLabel", settings );
	linenumbers:SetPos( 10,70 );
	linenumbers:SetSize( 200,20 );
	linenumbers:SetText( "Show Line Numbers" );
	linenumbers:SetValue( 1 );
	settings:SetVisible( false );
	fileBrowser.Settings.AddSheet( "HTML Reader", settings, "rbrowser/file_text1.vmt", "Text Reader Settings" );
end