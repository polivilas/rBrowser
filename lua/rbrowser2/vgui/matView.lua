--[[
	File Browser 2.0
	by Ryan 'Joudoki' Lewellen
	June 9th, 2008 - June 24th, 2008
--]]

PANEL = {};

PANEL.BackgroundMaterial = Material( "vgui/bg-lines" );
PANEL.ForegroundMaterial = Material( "effects/flashlight/logo" );

PANEL.BackgroundColor = Color ( 255,255,255,255 );
PANEL.ForegroundColor = Color( 255,255,255,255 );

PANEL.ActualWidth = 32;
PANEL.ActualHeight = 32;
PANEL.AspectRatio = 1;

PANEL.Border = 4;

PANEL.m_bBackground = true;
PANEL.DrawBackground = true;

function PANEL:Init( )
	self:SetMaterial( self.ForegroundMaterial );
end

function PANEL:SetColor( color )
	self.ForegroundColor = color;
end

function PANEL:SetVMT( strVMT )
	if ( !file.Exists( strVMT ) ) then
		print( "Error! None-existant vmt " .. strVMT .. " passed to mat viewer!" );
		return false;
	end
	
end

function PANEL:SetMaterial( Mat )
	// Everybody makes mistakes, 
	// that's why they put erasers on pencils.
	if ( type( Mat ) == "string" ) then
		self:SetImage( Mat )
	return end
	
	Mat:SetShader( "UnlitGeneric" );
	Mat:SetMaterialInt( "$vertexcolor", 1 );
	Mat:SetMaterialInt( "$vertexalpha", 1 );

	self.ForegroundMaterial = Mat
	
	if (!self.ForegroundMaterial) then return end
	
	local Texture = self.ForegroundMaterial:GetMaterialTexture( "$basetexture" )
	if ( Texture ) then
		self.ActualWidth = Texture:GetActualWidth()
		self.ActualHeight = Texture:GetActualHeight()
	else
		self.ActualWidth = 32
		self.ActualHeight = 32
	end
	
	self.AspectRatio = self.ActualWidth / self.ActualHeight;
end

function PANEL:SetImage( strImage )
	print( "Setting Image " .. strImage );
	--if ( !file.Exists( "materials/"..strImage..".vmt", true ) ) then
	--	return false
	--end

	self.ImageName = strImage

	local Mat = Material( strImage )

	//
	// If it's a vertexlitgeneric material we need to change it to be
	// UnlitGeneric so it doesn't go dark when we enter a dark room
	// and flicker all about
	//
	if ( string.find( Mat:GetShader(), "VertexLitGeneric" ) || string.find( Mat:GetShader(), "Cable" ) ) then
	
		local t = Mat:GetMaterialString( "$basetexture" )
		
		if ( t ) then
		
			local params = {}
			params[ "$basetexture" ] = t
			params[ "$vertexcolor" ] = 1
			params[ "$vertexalpha" ] = 1
			
			Mat = CreateMaterial( strImage .. "_DImage", "UnlitGeneric", params )
		
		end
		
	end
	
	self:SetMaterial( Mat )
end

function PANEL:Paint()
	-- Draw a solid background
	derma.SkinHook( "Paint", "PanelList", self );
	
	-- Draw our background image over that
	surface.SetDrawColor( 255,255,255,25 );
	surface.DrawRect( self.Border, self.Border, self:GetWide() - self.Border * 2, self:GetTall() - self.Border * 2 );
	
	-- Draw our image
	surface.SetDrawColor( self.ForegroundColor.r, self.ForegroundColor.g, self.ForegroundColor.b, self.ForegroundColor.a );
	surface.SetMaterial( self.ForegroundMaterial );
	
	local x = self.Border;
	local y = self.Border;
	
	local w = self.ActualWidth;
	local h = self.ActualHeight;
	
	-- First, determine if we actually need to resize
	if ( self.ActualWidth > self:GetWide() or self.ActualHeight > self:GetTall() ) then
		if ( self.AspectRatio >= 1 ) then
			-- Height has priority
			h = self:GetTall() - self.Border * 2;
			local ratio = h / self.ActualHeight;
			w = ratio * w;
			
			-- Center it on H
			y = ( ( self:GetWide() - self.Border * 2 ) /2 ) - ( self.ActualHeight / 2 ) + self.Border;
		else
			-- Width has priority
			w = self:GetWide() - self.Border * 2;
			local ratio = w / self.ActualWidth;
			h = ratio * h;
			
			-- Center on W
			x = ( ( self:GetTall() - self.Border * 2 ) /2 ) - ( self.ActualWidth / 2 ) + self.Border;
		end
	else
		-- Center it
			x = ( ( self:GetTall() ) /2 ) - ( self.ActualWidth / 2 );
			y = ( ( self:GetWide()  ) /2 ) - ( self.ActualHeight / 2 );
	end
	
	surface.DrawTexturedRect( x,y,w,h );
end


function PANEL:PaintNoStretch( mat, color, x, y, w, h )
	surface.SetMaterial( mat );
	surface.SetDrawColor( color.r, color.g, color.b, color.a );
	local tw, th = surface.GetTextureSize( surface.GetTextureID( matSrc ) ); --surface.GetTextureSize( surface.GetTextureID( "vgui/alpha-back" ) ) );
	
	local tileX = math.floor( ( w / tw ) + .99 );
	local tileY = math.floor( ( h / th ) + .99 );
	local stretchY = false;
	if ( th > h ) then
		tileY = 1;
		th=h;
	end
	
	for i=1, tileX do
		for k=1, tileY do
			surface.DrawTexturedRect( x + (i-1)*tw, y + (k-1)*th, tw, th );
		end
	end
end

vgui.Register( "matView", PANEL, "Panel" );