--[[
	File Browser 2.0
	by Ryan 'Joudoki' Lewellen
	June 9th, 2008 - June 24th, 2008
--]]

fileBrowser.extensions = {};
fileBrowser.extensions[ "dll" ] = { name="Dynamic Link Library", action=false, material="rbrowser/file_dll" };
fileBrowser.extensions[ "folder" ] = { name="Folder", action=false, material="rbrowser/folder" };
fileBrowser.extensions[ "7z" ] = { name="Compressed Folder ( LZMA )", action=false, material="rbrowser/folder" };
fileBrowser.extensions[ "zip" ] = { name="Compressed Folder ( ZIP )", action=false, material="rbrowser/folder" };
fileBrowser.extensions[ "rar" ] = { name="Compressed Folder ( RAR )", action=false, material="rbrowser/folder" };
fileBrowser.extensions[ "txt" ] = { name="Text file", action=textReader.Create, material="rbrowser/file_text2" };
fileBrowser.extensions[ "vdf" ] = { name="Valve Data File", action=textReader.Create, material="rbrowser/file_text2" };
fileBrowser.extensions[ "ini" ] = { name="Configuration File", action=textReader.Create, material="rbrowser/file_text2" };
fileBrowser.extensions[ "res" ] = { name="Resource List", action=textReader.Create, material="rbrowser/file_text2" };
fileBrowser.extensions[ "cfg" ] = { name="Configuration File", action=textReader.Create, material="rbrowser/file_text2" };
fileBrowser.extensions[ "lua" ] = { name="Lua Code File", action=textReader.Create, material="rbrowser/file_lua" };
fileBrowser.extensions[ "wav" ] = { name="Uncompressed Audio", action=soundPlayer.Create, material="rbrowser/file_audio" };
fileBrowser.extensions[ "mp3" ] = { name="Compressed Audio (mp3)", action=soundPlayer.Create, material="rbrowser/file_audio" };
fileBrowser.extensions[ "vtf" ] = { name="Material Source", action=matViewer.Create, material="rbrowser/file_material" };
fileBrowser.extensions[ "vmt" ] = { name="Material Definition", action=matViewer.Create, material="rbrowser/file_material" };
fileBrowser.extensions[ "bsp" ] = { name="Map", action=mapChanger.Create, material="rbrowser/file_material" };
fileBrowser.extensions[ "htm" ] = { name="HTML Markup File", action=htmlReader.Create, material="rbrowser/file_text1" };
fileBrowser.extensions[ "html" ] = { name="HTML Markup File", action=htmlReader.Create, material="rbrowser/file_text1" };
fileBrowser.extensions[ "css" ] = { name="Cascading Style Sheet", action=textReader.Create, material="rbrowser/file_text" };
fileBrowser.extensions[ "gif" ] = { name="GIF Image", action=imgViewer.Create, material="rbrowser/file_text1" };
fileBrowser.extensions[ "jpg" ] = { name="JPG Image", action=imgViewer.Create, material="rbrowser/file_text1" };
fileBrowser.extensions[ "jpeg" ] = { name="JPEG Image", action=imgViewer.Create, material="rbrowser/file_text1" };
fileBrowser.extensions[ "tga" ] = { name="TGA Image", action=false, material="rbrowser/file_text1" };
fileBrowser.extensions[ "png" ] = { name="PNG Image", action=imgViewer.Create, material="rbrowser/file_text1" };
fileBrowser.extensions[ "bmp" ] = { name="BMP Image", action=imgViewer.Create, material="rbrowser/file_text1" };

fileBrowser.Restore = false;

fileBrowser.filter = "*";
fileBrowser.folder = "";

function fileBrowser.ActionSound()
	if ( fileBrowser.Settings.Data[ "playsounds" ] == true ) then
		LocalPlayer():EmitSound( fileBrowser.sounds[ "file_open" ], 100, 100 );
	end
end

function fileBrowser.AddressBarChanged( value, manual )
	fileBrowser.ExpandTo( value  );
	
	if ( manual == true ) then
		local newHistory = fileBrowser.Settings.GetSetting( "folderhist_mostrecent" );
		if ( !newHistory ) then newHistory = 0; end
		newHistory = newHistory + 1;
		if ( newHistory == 11 ) then newHistory = 1 end
		local newHistoryIndex= "folderhist_" .. newHistory;
		print( "Setting history " .. newHistoryIndex .. " to " .. value );
		fileBrowser.Settings.SetSetting( newHistoryIndex, value );
		fileBrowser.Settings.SetSetting( "folderhist_mostrecent", newHistory );
	end
end

function fileBrowser.ExpandTo( expandTo )
	print("expandto")	
	-- Even if we can't expand to it in the folder view, open it in the file view
	fileBrowser.OpenFolder( expandTo, fileBrowser.window.filterBar:GetValue() );
	
	local dirs = string.Explode( "/", expandTo );
	local num = 0;
	for k,v in pairs( dirs ) do
		if ( v != "" ) then num = num + 1; end
	end
	
	local node = fileBrowser.window.folderList:GetItems()[1];
	local foundTo = 0;
	
	for i=1, num do
		local curVal = dirs[i];		
		local found = false;
		local last = false;
		if ( i == num ) then
			print( "Last one!" );
			last = true;
		end
		
		-- Before we look for the child, lets expand it
		node:InternalDoClick();
		node:SetExpanded( true );
		
		if ( !node.ChildNodes ) then
			print( "Couldn't go any farther" );
			break;
		end
		
		for k,v in pairs( node.ChildNodes.Items ) do
			if ( string.lower( v.fData.name ) == string.lower( curVal ) ) then
				found = true;
				foundTo = foundTo + 1;
				node = v;
				if ( last == true ) then
					node:InternalDoClick();
					node:SetExpanded( true );
				end
				break;
			end
		end
	end
end

function fileBrowser.OpenFile( fData )
	if ( fileBrowser.extensions[ fData.ext ] and fileBrowser.extensions[ fData.ext ].action != false ) then
		fileBrowser.extensions[ fData.ext ].action( fData );
	end
end

function fileBrowser.FilterChanged( newFilter )
	fileBrowser.filter = newFilter;
	
	if ( newFilter == "" ) then 
		fileBrowser.filter = "*";
		fileBrowser.window.filterBar:SetText( "*" );
	end
	
	fileBrowser.OpenFolder( fileBrowser.folder, fileBrowser.filter );
end

function fileBrowser.DoubleClick( fileList, id, line )
	if ( line.fData ) then 
		fileBrowser.OpenFile( line.fData );
	end
	fileBrowser.ActionSound();
end

function fileBrowser.RightClick( fileList, id, line )
	if not line.fData then return end
	local fData = line.fData;
	local menu = DermaMenu();
	
	menu:AddOption( "Open", function()
		fileBrowser.ContextOpen( fData );
		end
	);
	
	if ( fData.dir == false ) then
		menu:AddOption( "Open in Text Viewer", function()
			textReader.Create( fData );
			end
		);
		menu:AddOption( "Copy to Data", function()
			fileBrowser.CopyToData( fData );
			end
		);
	
		menu:AddOption( "Copy to Clipboard", function()
			fileBrowser.CopyToClipboard( fData );
			end
		);
	end
	
	menu:AddOption( "Properties", function()
		fileBrowser.ContextProperties( fData );
		end
	);
	menu:Open( nil, nil, nil, line );
end

--

function fileBrowser.CopyToClipboard( fData )
	fileBrowser.ActionSound();
	if not fData then print("no 'fData' @ fileBrowser.CopyToClipboard") return end
	local path = string.gsub( fData.path .. fData.name .. "." .. fData.ext, "%.%./", "" );
	if ( fData.dir == true ) then
		path = string.gsub( fData.path .. fData.name, "%.%./", "" );
	end	
	print( "Clipboard: [" .. path .. "]" );
	SetClipboardText( path );
end

function fileBrowser.CopyToData( fData )
	if not fData then print("no 'fData' @ fileBrowser.CopyToData") return end
	fileBrowser.ActionSound();
	path = fData.path .. fData.name .. "." .. fData.ext;
	print( "Data: [" .. path .. "]" );
	file.Write( fData.name .. "." .. fData.ext .. ".txt", file.Read( path ) );
end

function fileBrowser.ContextOpen( fData )
	if not fData then print("no 'fData' @ fileBrowser.ContextOpen") return end
	fileBrowser.ActionSound();
	fileBrowser.OpenFile( fData );
end

function fileBrowser.ContextProperties( fData )
	if not fData then print("no 'fData' @ fileBrowser.ContextProperties") return end
	propertiesReader.Create( fData );
	fileBrowser.ActionSound();
end

--

function fileBrowser.OpenFolder( folder, filter )
	if folder == "../" then
	folder = ""
	end
	local startTime = os.time();
	local numFiles = 0;
	fileBrowser.window.statusBar:SetText( "Opening [" .. folder .. "] Filter [" .. filter .. "]" );
	fileBrowser.ClearList();
	
	print( "Opening [" .. folder .. "] [" .. filter .. "]" );
	
	for k,v in pairs( fileBrowser.fileLibrary.getList( folder, filter ) ) do
		-- This is essentially the :AddColumn function, but I needed it to store data
		fileBrowser.window.fileList:SetDirty( true );
		fileBrowser.window.fileList:InvalidateLayout();
		
		local Line = vgui.Create( "DListView_Line", fileBrowser.window.fileList.pnlCanvas );
		local ID = table.insert( fileBrowser.window.fileList.Lines, Line );
		
		Line:SetListView( fileBrowser.window.fileList );
		Line:SetID( ID );
		
		if ( v.ext != "") then
			Line:SetColumnText( 1, v.name .. "." .. v.ext );
			if ( fileBrowser.extensions[ v.ext ] ) then				
				Line:SetColumnText( 2, fileBrowser.extensions[ v.ext ].name );
			else
				Line:SetColumnText( 2, "Unknown File Type" );
			end
		else
			Line:SetColumnText( 1, v.name  );
			Line:SetColumnText( 2, "Folder" );
		end
		
		Line.fData = v;
		
		local SortID = table.insert( fileBrowser.window.fileList.Sorted, Line );
		if ( SortID % 2 == 1 ) then
			Line:SetAltLine( true );
		end
		numFiles = numFiles + 1;
	end
	
	local newFolder = string.gsub( folder, "%.%./", "" );
	fileBrowser.window.addBar:SetText( newFolder );
	fileBrowser.folder = newFolder;

	local endTime = os.time();
	fileBrowser.window.statusBar:SetText( "Listed [" .. numFiles .. "] files in [" .. endTime - startTime .. "] seconds, [" .. ( endTime - startTime ) / numFiles .. "] seconds per file." );
end

function fileBrowser.ClearList()
	if ( fileBrowser.window.fileList ) then
		for k,v in pairs( fileBrowser.window.fileList:GetLines() ) do
			fileBrowser.window.fileList:RemoveLine( k );			
		end
	end
end

function fileBrowser.GetFolders( folder )
	print("getfolders")
	local fileData = {};
	print(folder)
	local files,folders = file.Find( folder .. "*","DATA" );
	table.sort( folders );
	
	for k,v in pairs( folders ) do
		local data = {};
		data.name = v;
		data.path = folder;
		
		fileData[ k ] = data;
	end
	
	return fileData;
end

function fileBrowser.ExpandItem( node )
	print("expanditem"..node.fData.name );
	if ( node.HasBeenExpanded == false ) then
		local folders = fileBrowser.GetFolders( node.fData.name );
		for k,v in pairs( folders ) do
			local cNode = node:AddNode( v.name );
			cNode.fData = v;
			cNode.DoClick = fileBrowser.ExpandItem;
			cNode.HasBeenExpanded = false;
		end
		node.HasBeenExpanded = true;
	end
	--fileBrowser.dir[ table.getn( fileBrowser.dir ) + 1 ] = fData.name;
	print( "Opening folder: " ..node.fData.name .. "/" .. fileBrowser.filter );
	fileBrowser.OpenFolder(node.fData.name .. "/", fileBrowser.filter);
end

function fileBrowser.Create()
	if ( fileBrowser.window ) then fileBrowser.window:Remove() end
	local bwser = vgui.Create( "DSizeableFrame" );
		bwser:SetPos( 10, 10 )
		bwser:SetSize( 800, 600 );
		bwser:SetTitle( "Resource Browser" );
		bwser:SetDraggable( true );
		bwser:SetMinSize( 800, 300 );
		bwser:SetMaxSize( 800, ScrH() );
		bwser.CustomLayout = function(pnl)
			pnl.actionBar:SetSize( pnl:GetWide() - 20, 55 );
			pnl.viewArea:SetSize( pnl:GetWide() - 20, pnl:GetTall() - 100 );	
			pnl.folderList:SetSize( 240, pnl:GetTall() - 108 );
			pnl.fileList:SetSize( 525, pnl:GetTall() - 108 );
		end
		bwser.btnClose.DoClick = function( btn )
			fileBrowser.Settings.Save();
			btn:GetParent():Close();
		end
		
	local actionBar = vgui.Create( "DPanelList", bwser );
		actionBar:SetPos( 10, 30 );
		actionBar:SetSize( 780, 55 );
		actionBar:EnableHorizontal( true );
		actionBar:SetPadding( 4 );
		actionBar:SetSpacing( 7 );

	local addBar = vgui.Create( "HistoryBox", bwser );
		--addBar:SetPos( 67, 30 );
		addBar:SetSize( 580, addBar:GetTall() );
		addBar:SetText( "" );
		addBar.OnValueChange = fileBrowser.AddressBarChanged;
		
		for i=1, 10 do
			local index = "folderhist_" .. i;
			local hist = fileBrowser.Settings.GetSetting( index );
			if ( hist ) then
				addBar:AddChoice( hist );
			end
		end
		
	local filterBar = vgui.Create( "HistoryBox", bwser );
		--filterBar:SetPos( 800 - 100, 30 );
		filterBar:SetSize( 90, filterBar:GetTall() );
		filterBar:SetText( fileBrowser.filter );
		filterBar.OnValueChange = fileBrowser.FilterChanged;
		filterBar:AddChoice( "*" );
		filterBar:AddChoice( "*.txt" );
		filterBar:AddChoice( "stargate*" );
		
	local addBarLabel = vgui.Create( "DLabel", bwser );
		addBarLabel:SetText( "Garrysmod/" );
		addBarLabel:SizeToContents();
		addBarLabel:SetSize( addBarLabel:GetWide(), addBar:GetTall() );
	local filterLabel = vgui.Create( "DLabel", bwser );
		filterLabel:SizeToContents();
		filterLabel:SetText( "Filter" );
		filterLabel:SetSize( filterLabel:GetWide(), filterBar:GetTall() );	
		
		actionBar:AddItem( addBarLabel );
		actionBar:AddItem( addBar );
		actionBar:AddItem( filterLabel );
		actionBar:AddItem( filterBar );		
	
	local statusBar = vgui.Create( "DTextEntry", bwser );
		statusBar:SetEditable( false );
		statusBar:AllowInput ( false );
		statusBar:SetEditable( false );
		statusBar:SetText( "Resource Browser Ready!" );
		statusBar:SetSize( 560, statusBar:GetTall() );
		actionBar:AddItem( statusBar );
	
	local openSettings = vgui.Create( "DButton", bwser );
		--openSettings:SetPos( 10, 60 );
		--openSettings:SetSize( 60, 20 );
		openSettings:SetText( "" );
		openSettings.DoClick = function()
			print( "Open Settings" );
			if ( fileBrowser.Settings and fileBrowser.Settings.window ) then
				fileBrowser.Settings.window:MakePopup( );
				fileBrowser.Settings.window:SetVisible( true );
			else
				print( "Warning: Settings window not initialized!" );
			end
		end
		openSettings.Paint = function(self, w, h)
			if self.Hovered then
				draw.RoundedBox(0, 0, 0, w, h, Color( 200, 200, 200, 255 ))
			else
				draw.RoundedBox(0, 0, 0, w, h, Color( 150, 150, 150, 255 ))
			end
			draw.SimpleText(
				"Settings",
				"DermaDefault",
				self:GetWide() / 2,
				3,
				color_white,
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_BOTTOM
			)
		end
		actionBar:AddItem( openSettings );

	local openFind = vgui.Create( "DButton", bwser );
		openFind:SetText( "" );
		openFind.DoClick = function()
			print( "Open Find" );
			if ( fileBrowser.Find and fileBrowser.Find.window ) then
				fileBrowser.Find.window:MakePopup( );
				fileBrowser.Find.window:SetVisible( true );
			else
				print( "Warning: Find window not initialized!" );
			end
		end
		openFind.Paint = function(self, w, h)
			if self.Hovered then
				draw.RoundedBox(0, 0, 0, w, h, Color( 200, 200, 200, 255 ))
			else
				draw.RoundedBox(0, 0, 0, w, h, Color( 150, 150, 150, 255 ))
			end
			draw.SimpleText(
				"Find in Files",
				"DermaDefault",
				self:GetWide() / 2,
				3,
				color_white,
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_BOTTOM
			)
		end
		actionBar:AddItem( openFind );
	
	local openHelp = vgui.Create( "DButton", bwser );
		openHelp:SetText( "" );
		openHelp.DoClick = function()
			print( "Open Help" );
			--if ( fileBrowser.Find and fileBrowser.Find.window ) then
				--fileBrowser.Find.window:MakePopup( );
				--fileBrowser.Find.window:SetVisible( true );
			--else
				--print( "Warning: Find window not initialized!" );
			--end
		end
		openHelp.Paint = function(self, w, h)
			if self.Hovered then
				draw.RoundedBox(0, 0, 0, w, h, Color( 200, 200, 200, 255 ))
			else
				draw.RoundedBox(0, 0, 0, w, h, Color( 150, 150, 150, 255 ))
			end
			draw.SimpleText(
				"Open Help",
				"DermaDefault",
				self:GetWide() / 2,
				3,
				color_white,
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_BOTTOM
			)
		end
		actionBar:AddItem( openHelp );
	
	local viewArea = vgui.Create( "DPanelList", bwser );
		viewArea:SetPos( 10, 90 );
		viewArea:SetSize( 780, 500 );
		viewArea:EnableHorizontal( true );
		viewArea:SetSpacing( 7 );
		viewArea:SetPadding( 4 );

	local folderList = vgui.Create( "DTree", bwser );
		folderList:SetSize( 240, 492 );
		local topNode = folderList:AddNode( "Garrysmod/" );
		topNode.fData = { name="", path=".." };
		topNode.DoClick = fileBrowser.ExpandItem;
		topNode.HasBeenExpanded = true;
		local folders = fileBrowser.GetFolders( "" );
		for k,v in pairs( folders ) do
			local node = topNode:AddNode( v.name );
			node.fData = v;
			node.DoClick = fileBrowser.ExpandItem;
			node.HasBeenExpanded = false;
		end
		topNode:SetExpanded( true );
		viewArea:AddItem( folderList );
		
	local fileList = vgui.Create( "DListView", bwser );
		fileList:SetSize( 525, 492 );
		fileList:SetMultiSelect( false );
		fileList:AddColumn( "Name" );
		fileList:AddColumn( "Extension" );
		fileList.DoDoubleClick = fileBrowser.DoubleClick;
		fileList.OnRowRightClick = fileBrowser.RightClick;
		viewArea:AddItem( fileList );
	
	bwser.actionBar = actionBar;
	bwser.addBarLabel = addBarLabel;
	bwser.addBar = addBar;
	bwser.filterLabel = filterLabel;
	bwser.filterBar = filterBar;
	bwser.viewArea = viewArea;
	bwser.fileList = fileList;
	bwser.folderList = folderList;
	bwser.statusBar = statusBar;
	bwser.actions = actions;
	bwser.openSettings = openSettings;
	bwser.openFind = openFind;
	bwser.openHelp = openHelp;
	
	bwser:SetDeleteOnClose( false );	
	fileBrowser.window = bwser;
	
	fileBrowser.window:SetVisible( false );
end