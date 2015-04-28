PANEL = {};

PANEL.PanelDragHoldPos = { x=0, y=0 };
PANEL.DragHoldPos = { x=0, y=0 };
PANEL.Dragging = false;


PANEL.SizingHoldPos = { x=0, y=0 };
PANEL.Sizing = false;

PANEL.Draggable = true;
PANEL.Sizeable = true;

PANEL.StayOnScreen = true;

function PANEL:Init()
	self.btnDrag = vgui.Create( "DSizeGrip", self )
	self.btnDrag:SetSize( 16,16 )
	
	self.lblTitle:Remove()
	
	self.close = vgui.Create("DButton", self)
	self.close:SetText("")
	self.close.DoClick = function()
		self:Close()
		gui.EnableScreenClicker(false)
	end
	self:ShowCloseButton(false)
	self.close.Paint = function(close, w, h)
		if close.Hovered then
			draw.RoundedBox(0, 0, 0, w, h, Color( 200, 200, 200, 255 ))
		else
			draw.RoundedBox(0, 0, 0, w, h, Color( 150, 150, 150, 255 ))
		end
		draw.SimpleText(
			"Close",
			"DermaDefault",
			close:GetWide() / 2,
			1,
			color_white,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_BOTTOM
		)
	end
end

function PANEL:SetTitle(text)
	self.Title = text
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color( 111, 111, 111, 255 ))
	draw.RoundedBox(0, 0, 0, w, 28, Color( 225, 225, 225, 255 ))
	draw.SimpleText(
		self.Title,
		"DermaDefault",
		10,
		7,
		color_black,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_BOTTOM
	)
end

function PANEL:Think()
	if ( self.Dragging == true and self.Draggable == true ) then
		local newPos = { x=0, y=0 };
		local x,y = gui.MousePos();
		newPos.x = self.PanelDragHoldPos.x + ( x - self.DragHoldPos.x );
		newPos.y = self.PanelDragHoldPos.y + ( y - self.DragHoldPos.y );
		if ( self.StayOnScreen == true ) then
			newPos.x = math.Clamp( newPos.x, 0, ScrW() - self:GetWide() );
			newPos.y = math.Clamp( newPos.y, 0, ScrH() - self:GetTall() );
		end
		self:SetPos( newPos.x, newPos.y );
		
		if ( input.IsMouseDown( MOUSE_LEFT ) == false ) then
			self.Dragging = false;
		end
	end
end

function PANEL:OnMousePressed( mc )
	if ( mc == MOUSE_LEFT and self.Draggable == true ) then
		--print( "Drag Start" );
		self.Dragging = true;
		self.DragHoldPos.x, self.DragHoldPos.y = gui.MousePos();
		self.PanelDragHoldPos.x, self.PanelDragHoldPos.y = self:GetPos();
	end
end
function PANEL:OnMouseReleased( mc )
	if ( mc == MOUSE_LEFT ) then
		--print( "Drag Stop" );
		self.Dragging = false;
	end
end

function PANEL:SetMinSize( w,h )
	self.btnDrag.MinSize.w = w;
	self.btnDrag.MinSize.h = h;
end

function PANEL:SetMaxSize( w,h )
	self.btnDrag.MaxSize.w = w;
	self.btnDrag.MaxSize.h = h;
end

function PANEL:SetSizeable( b )
	self.Sizeable = b;
end
function PANEL:GetSizeable( )
	return self.Sizeable;
end

function PANEL:SetDraggable( b )
	self.Draggable = b;
end
function PANEL:GetDraggable( )
	return self.Draggable;
end

function PANEL:PerformLayout()
	self:ShowCloseButton(false)
	derma.SkinHook( "Layout", "Frame", self );
	
	self.btnDrag:SetSize( 16, 16 );
	self.btnDrag:SetPos( self:GetWide() - 16, self:GetTall() - 16 );
	
	self.close:SetSize(48,16)
	self.close:SetPos(self:GetWide()-self.close:GetWide()-10,6)
	
	self.CustomLayout( self );
end

function PANEL.CustomLayout( panel )
	-- Override me
end

vgui.Register( "DSizeableFrame", PANEL, "DFrame" );

-- Testing
--[[
if ( sizeFrame ) then
	if ( sizeFrame.window ) then
		sizeFrame.window:Remove()
	end
end

sizeFrame = {};

local window = vgui.Create( "DSizeableFrame" );
	window:SetSize( 800,600 );
	window:Center();
	window:SetTitle( "Sizeable Frame Test" );
	window:MakePopup();
	window.CustomLayout = function( pnl )
		pnl.contents:SetSize( pnl:GetWide() - 20, pnl:GetTall() - 40 );	
	end
local contents = vgui.Create( "DPanelList", window );
	contents:SetPos( 10, 30 );
	contents:SetSize( 780, 560 );
	
window.contents = contents;
sizeFrame.window = window;
]]--