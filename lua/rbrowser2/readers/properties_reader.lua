--[[
	File Browser 2.0
	by Ryan 'Joudoki' Lewellen
	June 9th, 2008 - June 24th, 2008
--]]

-- For reading text or lua files
propertiesReader = {};
propertiesReader.Readers = {};

function propertiesReader.Create( fData )
	if ( !fData ) then
		return false end
		
	local extData = { name="Unknown Filetype", material="rbrowser/unknown" };
	if ( fileBrowser.extensions[ fData.ext ] ) then
		extData = fileBrowser.extensions[ fData.ext ];
	end
	if ( fData.dir == true ) then
		extData = fileBrowser.extensions[ "folder" ];
	end
		
	print( "Opening text file in reader: [" .. fData.path .. fData.name .. "." .. fData.ext .. "]" );
	
	local titleBarText = "";
	if ( fData.dir == true ) then
		titleBarText = tostring( fData.name ) .. " - Folder Properties";
	else
		titleBarText = tostring( fData.name ) .. "." .. tostring( fData.ext ) .. " - File Properties";
	end
	
	local fName = fData.name;
	local fType = "";
	local fPath = "garrysmod/" .. string.gsub( fData.path, "%.%./", "" );
	print( fData.path );
	print( fPath );
	if ( fData.dir == false ) then
		fName = fName .. "." .. fData.ext;
		fType = "." .. fData.ext .. " - ";
	end
	fType = fType .. extData.name;	
		
	local id = table.getn( propertiesReader.Readers ) + 1;
	local reader = vgui.Create( "DFrame" );
		reader:SetSize( 400,120 );
		reader:SetPos( 50,50 );
		reader:SetTitle( "[" .. tostring( fData.name ) .. "." .. tostring( fData.ext ) .. "] Resource Browser - File Properties" );
		reader:SetVisible( true );
		reader:SetDraggable( true );
		reader:ShowCloseButton( true );
		reader:MakePopup();

	local fileImage = vgui.Create( "DImage", reader );
		fileImage:SetPos( 30, 50 );
		fileImage:SetSize( 40, 40 );
		fileImage:SetImage( extData.material .. ".vmt" );
		
	local readerContents = vgui.Create( "DPanelList", reader );
		readerContents:SetSize( 290, 80 );
		readerContents:SetPos( 100, 30 );
		readerContents:SetPadding( 10 );
		readerContents:SetSpacing( 5 );
		readerContents:SetAutoSize( false );
		
	local fileName = vgui.Create( "DLabel", reader );		
		fileName:SetText( fName );
		fileName:SizeToContents();
		
	local fileType = vgui.Create( "DLabel", reader );
		fileType:SetText( fType );
		fileType:SizeToContents();
		
	local filePath = vgui.Create( "DLabel", reader );
		filePath:SetText( fPath );
		filePath:SizeToContents();
		
	local fileTime = vgui.Create( "DLabel", reader );
		fileTime:SetText( os.date( "%A, %B %d, %Y at %I:%M:%S %p", file.Time( fData.path .. fData.name .. "." .. fData.ext ) ) );
		fileTime:SizeToContents();
	
	readerContents:AddItem( fileName );
	readerContents:AddItem( fileType );
	readerContents:AddItem( filePath );
	readerContents:AddItem( fileTime );
		
	--reader.fileView = fileView;
	propertiesReader.Readers[id] = reader;
	return id;
	
end
function propertiesReader.Remove( ID )
	if ( propertiesReader.Readers[ ID ] ) then
		propertiesReader.Readers[ ID ]:Remove();
	end
end

function propertiesReader.MakeSettingsPanel()
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
	fileBrowser.Settings.AddSheet( "Text Reader", settings, "rbrowser/file_text1.vmt", "Text Reader Settings" );
end