--[[
	File Browser 2.0
	by Ryan 'Joudoki' Lewellen
	June 9th, 2008 - June 24th, 2008
--]]

-- For viewing materials
matViewer = {};
matViewer.Readers = {};

function matViewer.Create( fData )
	if ( !fData ) then
		return false end
	
	local matPath = string.gsub( fData.path .. fData.name, "../materials/", "" );
	print( "Opening material in reader: [" .. matPath .. "]" );
		
	local id = table.getn( matViewer.Readers ) + 1;
	local reader = vgui.Create( "DFrame" );
		reader:SetSize( 800,600 );
		reader:SetPos( 50,50 );
		reader:SetTitle( "[" .. tostring( fData.name ) .. "." .. tostring( fData.ext ) .. "] Resource Browser Material Viewer" );
		reader:SetVisible( true );
		reader:SetDraggable( true );
		reader:ShowCloseButton( true );
		reader:MakePopup();
		
	local contentPanel = vgui.Create( "DPanelList", reader );
		contentPanel:SetPos( 10,30 );
		contentPanel:SetSize( 200, 600-40 );
		contentPanel:SetSpacing( 20 );
		contentPanel:SetPadding( 10 );
	
	local r = vgui.Create( "DNumSlider", reader );
		r:SetText( "Red" );
		r:SetMin( 0 );
		r:SetValue( 255 );
		r:SetMax( 255 );
		r:SetDecimals( 1 );
		r.OnValueChanged = function( slider, value )
			local reader = slider:GetParent():GetParent():GetParent();
			local oldColor = reader.preview:GetColor();
			local newColor = Color( value, oldColor.g, oldColor.b, oldColor.a )
			reader.preview:SetColor( newColor );
			reader.mat:SetColor( newColor );
		end
		contentPanel:AddItem( r );
		
	local g = vgui.Create( "DNumSlider", reader );
		g:SetText( "Green" );
		g:SetMin( 0 );
		g:SetValue( 255 );
		g:SetMax( 255 );
		g:SetDecimals( 1 );
		g.OnValueChanged = function( slider, value )
			local reader = slider:GetParent():GetParent():GetParent();
			local oldColor = reader.preview:GetColor();
			local newColor = Color( oldColor.r, value, oldColor.b, oldColor.a );
			reader.preview:SetColor( newColor );
			reader.mat:SetColor( newColor );
		end
		contentPanel:AddItem( g );
		
	local b = vgui.Create( "DNumSlider", reader );
		b:SetText( "Blue" );
		b:SetMin( 0 );
		b:SetValue( 255 );
		b:SetMax( 255 );
		b:SetDecimals( 1 );
		b.OnValueChanged = function( slider, value )
			local reader = slider:GetParent():GetParent():GetParent();
			local oldColor = reader.preview:GetColor();
			local newColor = Color( oldColor.r, oldColor.g, value, oldColor.a )
			reader.preview:SetColor( newColor );
			reader.mat:SetColor( newColor );
		end
		contentPanel:AddItem( b );

	local a = vgui.Create( "DNumSlider", reader );
		a:SetText( "Alpha" );
		a:SetMin( 0 );
		a:SetValue( 255 );
		a:SetMax( 255 );
		a:SetDecimals( 1 );
		a.OnValueChanged = function( slider, value )
			local reader = slider:GetParent():GetParent():GetParent();
			local oldColor = reader.preview:GetColor();
			local newColor = Color( oldColor.r, oldColor.g, oldColor.b, value )
			reader.preview:SetColor( newColor );
			reader.mat:SetColor( newColor );
		end
		contentPanel:AddItem( a );	
		
	local previewLabel = vgui.Create( "DLabel", reader );
		previewLabel:SetText( "Color Preview: " );
		previewLabel:SizeToContents();
		contentPanel:AddItem( previewLabel );	
	
	local matColorPreview = vgui.Create( "DColouredBox", reader );
		matColorPreview:SetColor( Color( 255,255,255,255 ) );
		contentPanel:AddItem( matColorPreview );	
	
	local mat = vgui.Create( "matView", reader );
		mat:SetPos( 220, 30 );
		--mat:SetImageColor( Color( 255,255,255,255 ) );
		mat:SetImage( matPath );
		mat:SetSize( 800-230, 600-40 );
	
	--[[
	local originalSize = vgui.Create( "DLabel", reader );
		originalSize:SetText( "Original Size: n/a" );
		originalSize:SizeToContents();
		contentPanel:AddItem( originalSize );
	
	local openVMT = vgui.Create( "DButton", reader );
		openVMT:SetText( "Open .vmt in Text Viewer" );
		contentPanel:AddItem( openVMT );
	]]--	
	
	reader.mat = mat;
	reader.Content = contentPanel;
	reader.r = r;
	reader.g = g;
	reader.b = b;
	reader.a = a;
	reader.preview = matColorPreview;
	
	matViewer.Readers[id] = reader;
	return id;	
end
function matViewer.Remove( ID )
	if ( matViewer.Readers[ ID ] ) then
		matViewer.Readers[ ID ]:Remove();
	end
end
function matViewer.MakeSettingsPanel()
	--local settings = fileBrowser.Settings.AddSheet( "Material Viewer", "rbrowser/file_material.vmt", "Material Viewer Settings" );
	--fileBrowser.Settings.AddOption( settings, "checkbox", "Resize window to fit image",  "mat_resizewindow", true );
end