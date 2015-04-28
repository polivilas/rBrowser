--[[
	File Browser 2.0
	by Ryan 'Joudoki' Lewellen
	June 9th, 2008 - June 24th, 2008
--]]

local PANEL = {};

PANEL.LineHeight = 13;
PANEL.LineSpacing = 3;

PANEL.Text = "";
PANEL.LineData = {};

PANEL.VerticalScrollbar = true;
PANEL.HorizontalScrollbar = false;
PANEL.VScroll = nil;
PANEL.HScroll = nil;

PANEL.WordWrap = true;
PANEL.ShowLineNumbers = true;
PANEL.LineNumberWidth = 32;

PANEL.View = {};
PANEL.View.Line = 1;
PANEL.View.Column = 0;

PANEL.Viewable = {};
PANEL.Viewable.Lines = 36;
PANEL.Viewable.Columns = 500;

PANEL.Total = {};
PANEL.Total.Lines = 50;
PANEL.Total.Columns = 1000;

PANEL.TextPadding = {};
PANEL.TextPadding.x = 2;
PANEL.TextPadding.y = 2;

PANEL.Font = "Default";
PANEL.TextColor = Color( 255,255,255,255 );
PANEL.HighlightColor = Color( 0,128,255,255 );
PANEL.CursorColor = Color( 255,255,0,255 );
PANEL.m_bBackground = true;
PANEL.m_bBorder = true;

function PANEL:Init()
	self.Content = vgui.Create( "fileViewer_TextArea", self );
	
	self.VScroll = vgui.Create( "fileVScroller", self );
	self.VScroll:SetVisibleTicks( self.Viewable.Lines );
	self.VScroll:SetTotalTicks( 20 ); -- temp
	self.VScroll.OnScrolled = self.OnScrollbarMove;
	self.VerticleScrollbar = true;
	
	self.HScroll = vgui.Create( "fileHScroller", self );
	self.HScroll:SetVisibleTicks( self.Viewable.Lines );
	self.HScroll:SetTotalTicks( 20 ); -- temp
	self.HScroll.OnScrolled = self.OnHorizontalScroll;
	self.HScroll:SetVisible( false );
	self.HorizontalScrollbar = false;
end

function PANEL:SetLineHeight( height )
	self.LineHeight = height;
end

function PANEL:OnMouseWheeled( dlta )
	self.VScroll:MouseWheelInput( dlta );
end
function PANEL:OnScrollbarMove( tick )
	self.View.Line = tick;
	self.Content.View.Line = tick;
end
function PANEL:OnHorizontalScroll( tick )
	self.View.Column = -tick;
	self.Content.View.Column = -tick;
end

function PANEL:PerformLayout()
	local VScrollHeight = self:GetTall() - 2;
	local HScrollWidth = self:GetWide() - 2;
	if ( self.VerticleScrollbar == true and self.HorizontalScrollbar == true ) then
		VScrollHeight = VScrollHeight - 16;
		HScrollWidth = HScrollWidth - 16;
	end
	
	self.VScroll:SetSize( 16, VScrollHeight );
	self.VScroll:SetPos( self:GetWide() - 17, 1 );
	
	self.HScroll:SetSize( HScrollWidth, 16 );
	self.HScroll:SetPos( 1, self:GetTall() - 17 );
	
	local contentX = self.TextPadding.x;
	local contentW = self:GetWide() - self.TextPadding.x * 2 ;
	if ( self.ShowLineNumbers == true ) then
		contentX = contentX + self.LineNumberWidth;
		contentW = contentW - self.LineNumberWidth;
	end
	local contentH = self:GetTall() - self.TextPadding.y * 2;
	if ( self.VerticleScrollbar == true ) then
		contentW = contentW - 16;
	end
	if ( self.HorizontalScrollbar == true ) then
		contentH = contentH - 16;
	end
	
	self.Content:SetPos( contentX, self.TextPadding.y );
	self.Content:SetSize( contentW, contentH );
	self.Content:Update();
	
	self.VScroll:SetVisibleTicks( self.Viewable.Lines );
	self.HScroll:SetVisibleTicks( self.Viewable.Columns );
	self.VScroll:SetTotalTicks( self.Total.Lines );
	self.HScroll:SetTotalTicks( self.Total.Columns );
end

function PANEL:SetText( text )
	self.Content.Text = text;
	self.LineData = self.Content:WrapText( );
end
function PANEL:SetWordWrap( b )
	-- Reset Scroll
	self.VScroll:SetTickPos( 1 );
	self.View.Line = 1;
	self.Content.View.Line = 1;
	self.Content.WordWrap = b;
	self.Content:WrapText();
	
	if ( b == true ) then
		-- we don't need the horizontal scroller for wordwrapped text
		self.HScroll:SetVisible( false );
		self.HorizontalScrollbar = false;
		self:InvalidateLayout();
	else
		self.HScroll:SetVisible( true );
		self:InvalidateLayout();
		self.HorizontalScrollbar = true;
	end
end
function PANEL:SetLineNumbers( b )
	self.ShowLineNumbers = b;
	self:InvalidateLayout();
end

function PANEL:Update( vLines, vColumns, tLines, tColumns, LineData )
	--print( "fileViewer: Updating totals" );
	self.LineData = LineData;
	
	
	-- Variables
	self.Viewable.Lines = vLines;
	self.Viewable.Columns = vColumns;
	self.Total.Lines = tLines;
	self.Total.Columns = tColumns;
	
	-- Scrollbars
	if ( self.Viewable.Lines > self.Total.Lines ) then
		-- We don't need a verticle scrollbar
		self.VScroll:Enable( false );
	else
		self.VScroll:Enable( true );
	end
	self.VScroll:SetVisibleTicks( self.Viewable.Lines );
	self.HScroll:SetVisibleTicks( self.Viewable.Columns );
	self.VScroll:SetTotalTicks( self.Total.Lines );
	self.HScroll:SetTotalTicks( self.Total.Columns );
end

function PANEL:ApplySchemeSettings()
	derma.SkinHook( "Scheme", "TextEntry", self );
end

function PANEL:SetTextColor( color )
	self.TextColor = color;
end
function PANEL:SetHighlightColor( color )
	self.HighlightColor = color;
end
function PANEL:SetCursorColor( color )
	self.CursorColor = color;
end

function PANEL:Paint()
	--derma.SkinHook( "Paint", "TextEntry", self );
		
	local k = 1;
	local firstLine = self.View.Line;
	local lastLine = math.Clamp( firstLine + self.Viewable.Lines, firstLine, self.Total.Lines );
	local lastLineNumber = 0;
	
	if ( self.LineData ) then
		for i=firstLine, lastLine do
			local v = self.LineData[ i ];
			
			local y = ( k - 1 ) * ( self.LineHeight + self.LineSpacing ) + self.TextPadding.y;
			
			local x = self.TextPadding.x - self.View.Column;
			if ( self.ShowLineNumbers == true ) then 
				x = x + self.LineNumberWidth;
				if ( v ) then 
					if ( v.Line != lastLineNumber ) then
						draw.DrawText( v.Line, self.Font, 8, y, self.TextColor, 0 );
						lastLineNumber = v.Line;
					end
				end
			end		
			
			--draw.DrawText( v.Text, self.Font, x, y, self.TextColor, 0 );
			
			k = k + 1;
		end
	end
	
	return true;
end

vgui.Register( "fileViewer", PANEL, "Panel" );

--[[
-- Example
if ( fileViewer ) then
	if ( fileViewer.window ) then
		fileViewer.window:Remove();
	end
end

fileViewer = {};
	local window = vgui.Create( "DFrame" );
		window:SetSize( 800,600 );
		window:SetPos( 40,40 );
		window:SetTitle( "fileViewer Test" );
	local fileView = vgui.Create( "fileViewer", window );
		fileView:SetPos( 10,30 );
		fileView:SetSize( 800-20, 600-40 );
		fileView:SetText( file.Read( "../lua/rbrowser2/cl_browser.lua" ) );
fileViewer.window = window;
fileViewer.window.fileView = fileView;

fileViewer.window:MakePopup();
]]--