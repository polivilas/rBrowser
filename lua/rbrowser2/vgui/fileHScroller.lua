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

PANEL.OnScrolled = nil;
PANEL.Dragging = false;

PANEL.Drag = {};
PANEL.Drag.LocalX = 0;
PANEL.Drag.LocalXDest = 0;
PANEL.Drag.WorldX = 0;
PANEL.Drag.WorldXDest = 0;
PANEL.Drag.Tick = 0;
PANEL.Drag.TickDest = 0;

function PANEL:Init()
	self.btnLeft = vgui.Create( "DButton", self );
	--self.btnLeft:SetType( "left" );
	self.btnLeft.DoClick = function ( self ) self:GetParent():Move( 1 ); end
	self.btnLeft:SetSize( 16,16 );
	self.btnLeft:SetPos( 0,0 );
	
	self.btnRight = vgui.Create( "DButton", self );
	--self.btnRight:SetType( "right" );
	self.btnRight.DoClick = function ( self ) self:GetParent():Move( -1 ); end
	self.btnRight:SetSize( 16,16 );
	self.btnRight:SetPos( self:GetWide() - 16, 0 );
	
	self.btnGrip = vgui.Create( "fileScrollerGrip", self );
	self.btnGrip:SetSize( 16, self:GetTall() );
	self.btnGrip:SetPos( 16,0 );
end

function PANEL:Enable( b )
	self.Enabled = b;
	self.btnDown:SetDisabled( !b );
	self.btnUp:SetDisabled( !b );
end

function PANEL:TrackWidth()
	return self:GetWide() - self:GetTall() * 2;
end

function PANEL:UpdateGrip()
	local tall = self:GetTall();
	local newSize = ( self.VisibleTicks / ( self.TotalTicks -1 ) ) * self:TrackWidth();
	local newPos = tall + ( ( self.TickPos - 1 ) / ( self.TotalTicks - 1) ) * self:TrackWidth();
	newSize = math.Clamp(  newSize, 4, self:TrackWidth() );
	newPos = math.Clamp( newPos, tall, self:TrackWidth() + tall - newSize );
	self.btnGrip:SetSize( newSize, tall  );
	self.btnGrip:SetPos( newPos, 0 );
end


function PANEL:PerformLayout()
	self.btnLeft:SetPos( 0,0 );
	self.btnLeft:SetSize( self:GetTall(), self:GetTall() );
	
	self.btnRight:SetPos( self:GetWide() - self:GetTall(), 0 );
	self.btnRight:SetSize( self:GetTall(), self:GetTall() );
	
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
	local newTick = math.Clamp( tickPos, 1, self.TotalTicks + self:GetTall() - self.VisibleTicks );
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

function PANEL:GetTickAtX( x )
	x = x - self:GetTall();
	local tickRes = self:TrackWidth() / self.TotalTicks;
	local tick = math.Round( x / tickRes );
	return tick;
end

function PANEL:Think()
	if ( self.Dragging == true ) then
		local sX,sY = gui.MousePos();
		local x = ( sX - self.Drag.WorldX ) + self.Drag.LocalX;
		self.Drag.LocalXDest = x;
		self.Drag.WorldXDest = sX;
		
		local xOffset = sX - self.Drag.WorldX;
		local tickOffset = self:GetTickAtX( xOffset );

		local newTick = math.Clamp( self.Drag.TickPos + tickOffset, 1, self.TotalTicks - self.VisibleTicks );
		
		--print( "[ " .. tickOffset .. " ] [ " .. newTick .. " ]" );
		
		self:SetTickPos( newTick );
		if ( self.OnScrolled ) then self.OnScrolled( self:GetParent(), newTick ) end
		
		if ( input.IsMouseDown( MOUSE_LEFT ) == false ) then
			self.Dragging = false;
		end
	end
end

function PANEL:OnMousePressed( mc )
	if ( mc == MOUSE_LEFT ) then
		self.Dragging = true;
		
		-- Absolute
		local sX, sY = gui.MousePos();
		self.Drag.WorldX = sX;
		
		-- Relative
		local x,y = self:CursorPos();
		self.Drag.LocalX = x + self:GetTall();
		self.Drag.TickPos = self:GetTickAtX( x );
		
		--print( "Drag Start: [" .. sY .. "] [" .. y .. "] [" .. self.Drag.Tick .. "]" );
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
	derma.SkinHook( "Paint", "HScrollBar", self );
	return true;
end

vgui.Register( "fileHScroller", PANEL, "Panel" );