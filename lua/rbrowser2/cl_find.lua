--[[
	File Browser 2.0
	by Ryan 'Joudoki' Lewellen
	June 9th, 2008 - June 24th, 2008
--]]

if ( fileBrowser.Find ) then
	if ( fileBrowser.Find.window ) then
		fileBrowser.Find.window:Remove();
	end
end

fileBrowser.Find = {};

function fileBrowser.Find.Search()
	if ( !fileBrowser.Find.window ) then return false end
	
	fileBrowser.Find.ClearList();
	
	local filter = fileBrowser.Find.window.searchBox:GetValue() or "*";
	local folder = fileBrowser.Find.window.searchInBox:GetValue() or "";
	local searchRec = fileBrowser.Find.window.searchRec:GetChecked();
	
	if ( string.sub( folder, -1 ) != "/" ) then
		folder = folder .. "/";
	end
	
	folder = "../" .. folder;
	
	print( "Searching:" );
	print( "\tFilter: " .. filter );
	print( "\tFolder: " .. folder );
	print( "\tSubfolders: " .. tostring( searchRec ) );
	
	print( "\tSearch string: " .. folder .. filter );
	
	local start = os.time();
	local numFiles = 0;
	
	print( "result = fileBrowser.fileLibrary.Search( \"" .. folder .. "\", \"" .. filter .. "\", " .. tostring( searchRec ) .. " );" );	
	local result = fileBrowser.fileLibrary.Search( folder, filter, searchRec );
	
	for k,v in pairs( result ) do
		-- This is essentially the :AddColumn function, but I needed it to store data
		fileBrowser.Find.window.searchResults:SetDirty( true );
		fileBrowser.Find.window.searchResults:InvalidateLayout();
		
		local Line = vgui.Create( "DListView_Line", fileBrowser.Find.window.searchResults.pnlCanvas );
		local ID = table.insert( fileBrowser.Find.window.searchResults.Lines, Line );
		
		Line:SetListView( fileBrowser.Find.window.searchResults );
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
		Line:SetColumnText( 3, v.path );
		
		Line.fData = v;
		
		local SortID = table.insert( fileBrowser.Find.window.searchResults.Sorted, Line );
		if ( SortID % 2 == 1 ) then
			Line:SetAltLine( true );
		end
		numFiles = numFiles + 1;
	end

	
	local endTime = os.time();
end

function fileBrowser.Find.ClearList()
	if ( fileBrowser.Find.window.searchResults ) then
		for k,v in pairs( fileBrowser.Find.window.searchResults:GetLines() ) do
			fileBrowser.Find.window.searchResults:RemoveLine( k );
		end
	end
end

function fileBrowser.Find.Create()
	local window = vgui.Create( "DFrame" );
		window:SetSize( 800,600 );
		window:Center();
		window:SetTitle( "Resource Browser - Find in Files" );
		window:SetDraggable( true );
		window:ShowCloseButton( true );
		window:SetDeleteOnClose( false );
		window:SetVisible( false );
	local searchParams = vgui.Create( "DPanelList", window );
		searchParams:SetPos( 10,30 );
		searchParams:SetSize( 190, 600-40 );
		searchParams:SetPadding( 10 );
		searchParams:SetSpacing( 10 );
	local searchLabel = vgui.Create( "DLabel", window );
		searchLabel:SetText( "Search For:" );
		searchParams:AddItem( searchLabel );
	local searchBox = vgui.Create( "DTextEntry", window );
		searchBox:SetValue( "*" );
		searchParams:AddItem( searchBox );
	local searchInLabel = vgui.Create( "DLabel", window );
		searchInLabel:SetText( "Search In:" );
		searchParams:AddItem( searchInLabel );
	local searchInBox = vgui.Create( "DTextEntry", window );
		searchParams:AddItem( searchInBox );
	local searchRec = vgui.Create( "DCheckBoxLabel", window );
		searchRec:SetText( "Search subfolders?" );
		searchRec:SizeToContents();
		searchRec:SetValue( 1 );
		searchParams:AddItem( searchRec );
	local searchButton = vgui.Create( "DButton", window );
		searchButton:SetText( "Search!" );
		searchButton.DoClick = fileBrowser.Find.Search;
		searchParams:AddItem( searchButton );
	local searchResults = vgui.Create( "DListView", window );
		searchResults:SetPos( 210, 30 );
		searchResults:SetSize( 800-220, 600-40 );
		searchResults:AddColumn( "File" );
		searchResults:AddColumn( "Type" );
		searchResults:AddColumn( "Path" );
		searchResults.DoDoubleClick = fileBrowser.DoubleClick;
		searchResults.OnRowRightClick = fileBrowser.RightClick;
		
	window:MakePopup();
		
	window.searchLabel = searchLabel;
	window.searchBox = searchBox;
	window.searchInLabel = searchInLabel;
	window.searchInBox = searchInBox;
	window.searchRec = searchRec;
	window.searchButton = searchButton;
	window.searchResults = searchResults;
	fileBrowser.Find.window = window;
end