--[[
	File Browser 2.0
	by Ryan 'Joudoki' Lewellen
	June 9th, 2008 - June 24th, 2008
--]]

-- PURPOSE: A non-retarded version of the scrollbar
-- the DVScrollBar is just shit

local PANEL = {};

PANEL.TickPos = 1; -- What tick we're on
PANEL.VisibleTicks = 1; -- How many ticks are visible
PANEL.TotalTicks = 10; -- Total Ticks

PANEL.OnScrolled = nil; -- function hook. Syntax is Scrollbar.OnScrolled = function ( scrollbar, minTick ) end

PANEL.Dragging = false;

PANEL.Drag = {};
PANEL.Drag.LocalY = 0;
PANEL.Drag.LocalYDest = 0;
PANEL.Drag.WorldY = 0;
PANEL.Drag.WorldYDest = 0;
PANEL.Drag.TickPos = 0;
PANEL.Drag.TickDest = 0;

PANEL.Enabled = true;

function PANEL:Init()
	self.btnUp = vgui.Create( "DButton", self );
	--self.btnUp:SetType( "up" );
	self.btnUp.DoClick = function ( self ) self:GetParent():Move( -1 ); end
	self.btnUp:SetSize( 16,16 );
	self.btnUp:SetPos( 0,0 );
	
	self.btnDown = vgui.Create( "DButton", self );
	--self.btnDown:SetType( "down" );
	self.btnDown.DoClick = function ( self ) self:GetParent():Move( 1 ); end
	self.btnDown:SetSize( 16,16 );
	self.btnDown:SetPos( 0, self:GetTall() - 16 );
	
	self.btnGrip = vgui.Create( "fileScrollerGrip", self );
	self.btnGrip:SetSize( self:GetWide(), 16 );
	self.btnGrip:SetPos( 0, 16 );
end

function PANEL:Enable( b )
	self.Enabled = b;
	self.btnDown:SetDisabled( !b );
	self.btnUp:SetDisabled( !b );
end

function PANEL:TrackHeight()
	return self:GetTall() - self:GetWide() * 2;
end

function PANEL:UpdateGrip()
	local wide = self:GetWide();
	local newSize = ( self.VisibleTicks / ( self.TotalTicks -1 ) ) * self:TrackHeight();
	local newPos = wide + ( ( self.TickPos - 1 ) / ( self.TotalTicks - 1) ) * self:TrackHeight();
	newSize = math.Clamp(  newSize, 4, self:TrackHeight() );
	newPos = math.Clamp( newPos, self:GetWide(), self:TrackHeight() + self:GetWide() - newSize );
	self.btnGrip:SetSize( wide, newSize  );
	self.btnGrip:SetPos( 0, newPos );
end

function PANEL:PerformLayout()
	self.btnUp:SetPos( 0,0 );
	self.btnUp:SetSize( self:GetWide(), self:GetWide() );
	
	self.btnDown:SetPos( 0, self:GetTall() - self:GetWide() );
	self.btnDown:SetSize( self:GetWide(), self:GetWide() );
	
	self:UpdateGrip();
end

function PANEL:Move( dlta )
	self:SetTickPos( self.TickPos + dlta );
	self:UpdateGrip();
	
	if ( self.OnScrolled ) then self.OnScrolled( self:GetParent(), self.TickPos ) end
end

-- Compatibility
function PANEL:GetScroll()
	return self.TickPos;
end

function PANEL:SetTickPos( tickPos )
	if ( self.Enabled == false ) then return false end
	local newTick = math.Clamp( tickPos, 1, self.TotalTicks + self:GetWide() - self.VisibleTicks );
	self.TickPos = newTick;
	self:UpdateGrip();
end

function PANEL:SetVisibleTicks( visibleTicks )
	self.VisibleTicks = visibleTicks;
	self:UpdateGrip();
end

function PANEL:SetTotalTicks( totalTicks )
	self.TotalTicks = totalTicks;
	self:UpdateGrip();
end

function PANEL:GetTickAtY( y )
	y = y - self:GetWide();
	local tickRes = self:TrackHeight() / self.TotalTicks;
	local tick = math.Round( y / tickRes );
	return tick;
end

function PANEL:Think()
	if ( self.Dragging == true ) then
		local sX,sY = gui.MousePos();
		local y = ( sY - self.Drag.WorldY ) + self.Drag.LocalY;
		self.Drag.LocalYDest = y;
		self.Drag.WorldYDest = sY;
		--self.Drag.TickDest = 
		
		local yOffset = sY - self.Drag.WorldY;
		local tickOffset = self:GetTickAtY( yOffset );
		
		local newTick = math.Clamp( self.Drag.TickPos + tickOffset, 1, self.TotalTicks - self.VisibleTicks );
		
		--print( "[ " .. tickOffset .. " ] [ " .. newTick .. " ]" );
		
		self:SetTickPos( newTick );
		if ( self.OnScrolled ) then self.OnScrolled( self:GetParent(), newTick ) end
		
		if ( input.IsMouseDown( MOUSE_LEFT ) == false ) then
			self.Dragging = false;
			--print( "Drag Stop" );
		end
	end
end

function PANEL:OnMousePressed( mc )
	if ( mc == MOUSE_LEFT and self.Enabled == true ) then
		self.Dragging = true;
		
		-- Absolute
		local sX, sY = gui.MousePos();
		self.Drag.WorldY = sY;
		
		-- Relative
		local x,y = self:CursorPos();
		self.Drag.LocalY = y + self:GetWide();
		self.Drag.TickPos = self:GetTickAtY( y );
	end
end

function PANEL:MouseWheelInput( dlta )
	if ( self.Enabled == false ) then return false end
	-- If we can see more than we have, we don't need to scroll
	if ( self.VisibleTicks > self.TotalTicks ) then return false end
	
	local newTick = math.Clamp( self.TickPos - dlta, 1, self.TotalTicks - self.VisibleTicks );
	self:SetTickPos( newTick )
	
	if ( self.OnScrolled ) then self.OnScrolled( self:GetParent(), newTick ) end
end

function PANEL:Paint()
	--derma.SkinHook( "Paint", "VScrollBar", self );
	--surface.SetDrawColor( 0,0,0,255 );
	--surface.DrawRect( 2, self.ScrollbarGripPos, self:GetWide() - 4, self.ScrollbarGripSize );
	return true;
end

vgui.Register( "fileVScroller", PANEL, "Panel" );