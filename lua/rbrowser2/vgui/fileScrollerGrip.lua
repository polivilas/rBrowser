PANEL = {};


function PANEL:OnMousePressed( mc )
	self:GetParent():OnMousePressed( mc );
end

 function PANEL:Paint(w, h)
surface.SetDrawColor( 255,0,255,255 );
surface.DrawRect( 0,0,self:GetWide(), self:GetTall() );
--derma.SkinHook( "Paint", "ScrollBarGrip", self, w, h )
return true

end


vgui.Register( "fileScrollerGrip", PANEL, "Panel" );