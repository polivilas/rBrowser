PANEL = {};

function PANEL:OnMousePressed( mc )
	self:GetParent():OnMousePressed( mc );
end

 function PANEL:Paint(w, h)
	surface.SetDrawColor( 200, 200, 200, 255 );
	surface.DrawRect( 0, 0, w, h );
	
	return true
end

vgui.Register( "fileScrollerGrip", PANEL, "Panel" );