--[[
	File Browser 2.0
	by Ryan 'Joudoki' Lewellen
	June 9th, 2008 - June 24th, 2008
--]]

MB_OK = 1;
MB_CONFIRM = 2;

MB_ICON_OK = "vgui/notices/generic.vmt";
MB_ICON_WARN = "vgui/notices/error.vmt";
MB_ICON_CONFIRM = "vgui/notices/hint.vmt";

PANEL = {};

PANEL.Type = 1;

function PANEL:Init()
	self:SetTitle( "Message Box" );
	self.Contents = vgui.Create( "DPanelList", self );
	self.Contents:SetSize( self:GetWide() - 20, self:GetTall() - 40 );
	self.Contents:SetPos( 50, 30 );
	self.Contents:SetPadding( 4 );
	self.Contents:SetSpacing( 4 );
	
	self.Icon = vgui.Create( "DImage", self );
		self.Icon:SetPos( 15, 35 );
		self.Icon:SetSize( 40, 40 );
		self.Icon:SetImage( "vgui/notices/error.vmt" );
	
	self.Msg = vgui.Create( "DLabel", self );
		self.Msg:SetText( "Hello world!" );
	self.Contents:AddItem( self.Msg );
end

function PANEL:SetIcon( mb_icon )
	self.Icon:SetImage( mb_icon );
end

--[[function PANEL:SetType( mb_type )
	if ( mb_type == 2 ) then
		local yes = vgui.Create( "DButton", self );
			yes:SetText( "Yes" );
			yes.DoClick = function() self.Confirm_Yes(); self:Close(); end
		local no = vgui.Create( "DButton", self );
			no:SetText( "No" );
			no.DoClick = function() self.Confirm_No(); self:Close(); end
		local cancel = vgui.Create( "DButton", self );
			cancel:SetText( "Cancel" );
			cancel.DoClick = function() self.Confirm_Cancel(); self:Close(); end		
		self.Contents:AddItem( yes );
		self.Contents:AddItem( no );
		self.Contents:AddItem( cancel );
	else
		local ok = vgui.Create( "DButton", self );
			ok:SetText( "Ok" );
			ok.DoClick = function() self.Ok(); self:Close(); end
		self.Contents:AddItem( ok );
	end
	self.Type = mb_type;
end]]

function PANEL.Confirm_Yes()
	-- override me
end
function PANEL.Confirm_Cancel()
	-- override me
end
function PANEL.Ok()
	-- override me
end

function PANEL:SetText( txt )
	self.Msg:SetText( txt );
	self.Msg:SizeToContents();
	local w,h = surface.GetTextSize( txt );
	local addHeight = 0;
	if ( self.Type == 1 ) then
		-- Only need room for row of text, button, and margins
		addHeight = 80;
	elseif ( self.Type == 2 ) then
		-- Need room for text, two buttons, marigns
		addHeight = 130;
	end
	
	self:SetSize( w + 108, h + addHeight );
end

function PANEL:PerformLayout()
	derma.SkinHook( "Layout", "Frame", self );
	self.Contents:SetSize( self:GetWide() - 80, self:GetTall() - 40 );
	self.Contents:SetPos( 70, 30 );
	return true;
end

vgui.Register( "DMessageBox", PANEL, "DFrame" );

--[[
Testing
if ( mBox ) then
	mBox:Remove()
end

mBox = vgui.Create( "DMessageBox" );
	mBox:SetType( MB_CONFIRM );
	mBox:SetIcon( MB_ICON_CONFIRM );
	mBox:SetText( "DO YOU LIKE PIE? I FUCKING LOVE PIE!" );
	mBox:Center();
]]--