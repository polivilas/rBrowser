-- Based on the DMultiChoice control
PANEL = {};

function PANEL:Init()

	self.MaxHistory = 10;

	self.DropButton = vgui.Create( "DButton", self );
	--self.DropButton:SetType( "down" );
	self.DropButton.OnMousePressed = function( button, mcode ) self:OpenMenu( self.DropButton ) end
	
	self.TextEntry = vgui.Create( "DTextEntry", self );
	self.TextEntry.OnMousePressed = function( button, mcode ) self:OpenMenu( self.TextEntry ) end
	self.TextEntry.OnEnter = function( txt ) self.OnValueChange( txt:GetValue(), true ) end
	self.TextEntry:SetEditable( true );
	
	// Nicer default height
	self:SetTall( 20 );
	
	self.Choices = {};
	self.Data = {};

end

function PANEL:Clear()

	self.TextEntry:SetText( "" );
	self.Choices = {};
	self.Data = {};

	if ( self.Menu ) then
		self.Menu:Remove();
		self.Menu = nil;
	end
	
end

function PANEL:SetText( text )

	self.TextEntry:SetText( text );

end

function PANEL:GetText( )

	self.TextEntry:GetValue();
	
end

function PANEL:GetOptionText( id )

	return self.Choices[ id ];

end

function PANEL:PerformLayout()

	derma.SkinHook( "Layout", "MultiChoice", self );

end

function PANEL:ChooseOption( value, index )

	if ( self.Menu ) then
		self.Menu:Remove();
		self.Menu = nil;
	end

	self:SetText( value );

	--self:OnSelect( index, value, self.Data[index] );
	self.OnValueChange( value, false );
end

function PANEL.OnValueChange( newValue, manuallyEntered )
	-- Override me
end

function PANEL:AddChoice( value, data )

	local i = table.insert( self.Choices, value );
	
	if ( data ) then
		self.Data[ i ] = data;
	end
	
	return i;

end

function PANEL:OpenMenu( pControlOpener )

	if ( pControlOpener ) then
		if ( pControlOpener == self.TextEntry ) then
			return;
		end
	end

	// Don't do anything if there aren't any options..
	if ( #self.Choices == 0 ) then return end
	
	// If the menu still exists and hasn't been deleted
	// then just close it and don't open a new one.
	if ( self.Menu ) then
		self.Menu:Remove();
		self.Menu = nil;
		return;
	end

	self.Menu = DermaMenu();
	
		for k, v in pairs( self.Choices ) do
			self.Menu:AddOption( v, function() self:ChooseOption( v, k ) end );
		end
		
		local x, y = self:LocalToScreen( 0, self:GetTall() );
		
		self.Menu:SetMinimumWidth( self:GetWide() );
		self.Menu:Open( x, y, false, self );
		

end

function PANEL:OnMousePressed( button, mcode )

	self:OpenMenu();

end

vgui.Register( "HistoryBox", PANEL, "Panel" );