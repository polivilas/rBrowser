PANEL = {};

function PANEL:Init()
	self.Sizing = false;
	self.Enabled = true;

	self.StayOnScreen = false;
	self.ObeySizeRules = true;

	self.GripColor = Color( 255,255,255,255 );
	self.SizeHoldPos = { x=0, y=0 };
	self.SizeHoldSize = { w=0, h=0 };
	self.MinSize = { w=40, h=30 };
	self.MaxSize = { w=ScrW(), h=ScrH() };
end

function PANEL:OnMousePressed( mc )
	if ( mc == MOUSE_LEFT and self.Enabled == true ) then
		--print( "Size Start" );
		self.Sizing = true;
		self.SizeHoldPos.x, self.SizeHoldPos.y = gui.MousePos();
		self.SizeHoldSize.w, self.SizeHoldSize.h = self:GetParent():GetSize();
	end
end

function PANEL:Think()
	if ( self.Sizing == true ) then
		if ( input.IsMouseDown( MOUSE_LEFT ) == false ) then
			self.Sizing = false;
			--print( "Drag Stop" );
		end
		local newSize = { w=0, h=0 };
		local x, y = gui.MousePos();
		newSize.w = self.SizeHoldSize.w + ( x - self.SizeHoldPos.x );
		newSize.h = self.SizeHoldSize.h + ( y - self.SizeHoldPos.y );
		if ( self.ObeySizeRules == true ) then
			newSize.w = math.Clamp( newSize.w, self.MinSize.w, self.MaxSize.w );
			newSize.h = math.Clamp( newSize.h, self.MinSize.h, self.MaxSize.h );
		end
		self:GetParent():SetSize( newSize.w, newSize.h );
	end
end

function PANEL:Enable( b )
	self.Enabled = b;
end

function PANEL:Paint()
	local w,h = self:GetSize();

	surface.SetDrawColor( self.GripColor.r, self.GripColor.g, self.GripColor.b, self.GripColor.a );
	surface.DrawLine( (4/5) * w, (1/5) * h, (1/5)*w, (4/5) * h );
	surface.DrawLine( (4/5) * w, (2/5) * h, (2/5)*w, (4/5) * h );
	surface.DrawLine( (4/5) * w, (3/5) * h, (3/5)*w, (4/5) * h );
end

vgui.Register( "DSizeGrip", PANEL, "Panel" );