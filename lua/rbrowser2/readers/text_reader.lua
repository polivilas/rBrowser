--[[
	File Browser 2.0
	by Ryan 'Joudoki' Lewellen
	June 9th, 2008 - June 24th, 2008
--]]

-- For reading text or lua files
textReader = {};
textReader.Readers = {};

function textReader.Create( fData )
	if ( !fData ) then
		return false end
		
	print( "Opening text file in reader: [" .. fData.path .. fData.name .. "." .. fData.ext .. "]" );
		
	local id = table.getn( textReader.Readers ) + 1;
	local reader = vgui.Create( "DSizeableFrame" );
		reader:SetSize( 800,600 );
		reader:Center();
		reader:SetTitle( tostring( fData.name ) .. "." .. tostring( fData.ext ) .. " - Text Reader" );
		reader:SetVisible( true );
		reader:SetDraggable( true );
		reader:SetSizable( true );
		reader:ShowCloseButton( true );
		reader:MakePopup();
		reader:SetMinSize( 500,300 );
		reader:SetMaxSize( ScrW(), ScrW() );
		reader.CustomLayout = function(pnl)
			pnl.fileView:SetSize( pnl:GetWide() - 20, pnl:GetTall() - 75 );
			pnl.fileActions:SetSize( pnl:GetWide() - 20, 30 );
		end
	local fileActions = vgui.Create( "DPanelList", reader );
		fileActions:SetPos( 10, 30 );
		fileActions:SetSize( 780, 30 );
		fileActions:SetPadding( 5 );
		fileActions:SetSpacing( 10 );
		fileActions:EnableHorizontal( true );
	local wordWrap = vgui.Create( "DCheckBoxLabel", reader );
		wordWrap:SetText( "Word Wrap" );
		wordWrap:SetValue( fileBrowser.Settings.GetSetting( "text_alwayswordwrap" ) );
		wordWrap:SizeToContents();
		wordWrap:SetSize( wordWrap:GetWide() + 4, 20 );
		wordWrap.OnChange = function( chkBox, b )
			--msgTable( arg );
			--0print( "Wordwrap: " .. tostring( b ) );
			reader.fileView:SetWordWrap( b );
		end
	local lineNumb = vgui.Create( "DCheckBoxLabel", reader );
		lineNumb:SetText( "Show Line Numbers" );
		lineNumb:SetValue( fileBrowser.Settings.GetSetting( "text_linenumbers" ) );
		lineNumb:SizeToContents();
		lineNumb:SetSize( lineNumb:GetWide() + 4, 20 );
		lineNumb.OnChange = function( chkBox, b )
			reader.fileView:SetLineNumbers( b );		
		end
	local copyData = vgui.Create( "DButton", reader );
		copyData:SetText( "Copy to Data" );
		copyData:SizeToContents();
		copyData:SetSize( copyData:GetWide() + 4, 20 );
		copyData.DoClick = function() 
				path = fData.path .. fData.name .. "." .. fData.ext;
				print( "Data: [" .. path .. "]" );
				file.Write( fData.name .. "." .. fData.ext .. ".txt", file.Read( path ) );
		end
	local openSettings = vgui.Create( "DButton", reader );
		openSettings:SetText( "Open Settings" );
		openSettings:SizeToContents();
		openSettings:SetSize( openSettings:GetWide() + 4, 20 );
		openSettings.DoClick = function()
			fileBrowser.Settings.window:MakePopup( );
			fileBrowser.Settings.window:SetVisible( true );
		end
		
	fileActions:AddItem( wordWrap );
	fileActions:AddItem( lineNumb );
	fileActions:AddItem( copyData );
	fileActions:AddItem( openSettings );
	
	local fileView = vgui.Create( "fileViewer", reader );
		fileView:SetPos( 10,65 );
		fileView:SetSize( 800-20, 600-75 );
		fileView.Lines = 33;
		fileView:SetText( file.Read( fData.path .. fData.name .. "." .. fData.ext ) );
		fileView:SetWordWrap( fileBrowser.Settings.GetSetting( "text_alwayswordwrap" ) );
		fileView:SetLineNumbers( fileBrowser.Settings.GetSetting( "text_linenumbers" ) );
		
	reader.fileActions = fileActions;
	reader.wordWrap = wordWrap;
	reader.scrollbarMode = scrollbarMode; 
	reader.fileView = fileView;
	textReader.Readers[id] = reader;
	
	return reader, id;	
end
function textReader.Remove( ID )
	if ( textReader.Readers[ ID ] ) then
		textReader.Readers[ ID ]:Remove();
	end
end

function textReader.MakeSettingsPanel()
	local settings = fileBrowser.Settings.AddSheet( "Text Reader", "rbrowser/file_text1.vmt", "Text Reader Settings" );
	fileBrowser.Settings.AddOption( settings, "checkbox", "Wordwrap by Default", "text_alwayswordwrap", true );
	fileBrowser.Settings.AddOption( settings, "checkbox", "Show Line Numbers by Default", "text_linenumbers", true );
end