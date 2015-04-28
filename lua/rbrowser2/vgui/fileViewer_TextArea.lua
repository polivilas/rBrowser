PANEL = {};

PANEL.LineHeight = 13;
PANEL.LineSpacing = 3;

PANEL.View = {};
PANEL.View.Line = 1;
PANEL.View.Column = 0;

PANEL.Viewable = {};
PANEL.Viewable.Lines = 32;
PANEL.Viewable.Columns = 400;

PANEL.Total = {};
PANEL.Total.Lines = 40;
PANEL.Total.Columns = 1000;

PANEL.Font = "Default";
PANEL.TextColor = Color( 255,255,255,255 );
PANEL.HighlightColor = Color( 0,128,255,255 );
PANEL.CursorColor = Color( 255,255,0,255 );

PANEL.WordWrap = true;

PANEL.LineData = {};

function PANEL:Paint()
	--derma.SkinHook( "Paint", "TextEntry", self );
	
	--surface.SetDrawColor( 255,0,0,5 );
	--surface.DrawRect( 0,0,self:GetWide(),self:GetTall() );
	

	local k = 1;
	local firstLine = self.View.Line;
	local lastLine = math.Clamp( firstLine + self.Viewable.Lines, firstLine, #self.LineData );
	local lastLineNumber = 0;
	
	for i=firstLine, lastLine do
		local v = self.LineData[ i ];		
		local y = ( k - 1 ) * ( self.LineHeight + self.LineSpacing );
		
		if ( v ) then
			draw.DrawText( v.Text, self.Font, self.View.Column + 1, y, self.TextColor, 0 );
		end
	
		k = k + 1;
	end
	
	return true;

end

function PANEL:PerformLayout()
	-- Word wrap again
	if ( self.WordWrap == true ) then
		self:WrapText();
	end
	
	self:Update();
end

function PANEL:WrapText( )
	local text = self.Text;
	
	if ( !self.Text ) then return false end
	
	-- For compatibility, replace \t with five spaces
	text = string.gsub( self.Text, "\t", "     " );
	
	-- Annotate the text; insert line breaks where needed
	surface.SetFont( self.Font ); -- For getting the size of each word
	
	local xSpace = self:GetWide();
	local xUsedSpace = 0;
	
	local lines = {};
	local curLine = "";
	local curLineNum = 1;
	local curLoop = 1;
	local maxLoops = 500; -- inf loop protecton ( temporary )
	local curIndex = 0;
	local fuckthisshit = true
	local lineNumber = 1;
	
	while( fuckthisshit == true ) do
		-- First, check for line breaks in the file
		--print( "Searching at index " .. curIndex .. "." );
		local lbS, lbE = string.find( text, "\n", curIndex);
		local lastParagraph = false;
		if ( ! ( lbS and lbE ) ) then
			lastParagraph = true;
		end
		if ( ( lbS and lbE ) or lastParagraph == true ) then
			local searchArea = "";
			if ( lastParagraph == true ) then
				--print( "Last Paragraph!" );
				searchArea = string.sub( text, curIndex );
			else
				--print( "Paragraph between [" .. curIndex .. "] and [" .. lbS - 1 .. "]." );
				searchArea = string.sub( text, curIndex, lbE );				
			end
			
			-- Parse this paragraph
			local subIndex = 0;
			local parse = self.WordWrap;
			while( parse == true ) do
				local s,e = string.find( searchArea, "[^%s]+", subIndex );
				if ( s and e ) then
					local word = string.sub( searchArea, s, e );
					local w, h = surface.GetTextSize( word .. " " );
				
					if ( xUsedSpace + w <= xSpace ) then
						-- add to current line
						--print( "Adding [" .. word .. "] to line [" .. curLineNum .. "]" );
						curLine = curLine .. " " .. word;
						xUsedSpace = xUsedSpace + w;
					else
						-- new line
						--print( "Line [" .. curLineNum .. "] finished!" );
						lines[ curLineNum ] = {};
						lines[ curLineNum ].Text = curLine;				
						lines[ curLineNum ].Line = lineNumber;
						
						curLineNum = curLineNum + 1;
						curLine = "";
						xUsedSpace = 0;
					end

				--	print( "Word: [" .. s .. ", " .. e .. "] : " .. word .. " : [" .. w .. "," .. h .. "]" );
					subIndex = e+1;
				else
					-- Done parsing this this paragraph
					parse = false;
				end
			end
			
			-- Reset line
			lines[ curLineNum ] = {};
			if ( self.WordWrap == true ) then
				lines[ curLineNum ].Text = curLine;
			else
				lines[ curLineNum ].Text = searchArea;
			end
			lines[ curLineNum ].Line = lineNumber;
			curLineNum = curLineNum + 1;
			curLine = "";
			xUsedSpace = 0;
			
			-- Line number
			lineNumber = lineNumber + 1;
			
			print( "Done parsing paragraph." );			
			if ( lastParagraph == true ) then 
				print( "Done parsing file!" );
				fuckthisshit = false;
				break;
			else
				curIndex = lbE + 1;
			end
		else			
				-- No more characters
				print( string.sub( text, curIndex ) );
				fuckthisshit = false;
		end		
		--print( "Done.\n\n" );
	end
	
	self.LineData = lines;	
	self:Update();
	
	return lines;
end

function PANEL:LongestLine()
	if ( self.WordWrap == true ) then
		return self:GetWide();
	end
	
	local longLine = 1000;
	local lineLength = 0;
	
	for k,v in pairs( self.LineData ) do 
		if ( v.Text ) then
			lineLength = surface.GetTextSize( v.Text );
			if ( lineLength > longLine ) then
				longLine = lineLength;
			end
		end
	end
	
	return longLine + 5;	
end

function PANEL:Update()
	-- This function updatse the total lines, columns, and viewable lines, columns, on itself and on the parent
	--print( "TextArea: Updating Values" );
	self.Viewable.Lines = math.floor( self:GetTall() / ( self.LineHeight + self.LineSpacing ) ) - 1;
	self.Viewable.Columns = self:GetWide();
	self.Total.Lines = #self.LineData;
	self.Total.Columns = self:LongestLine();
	--print( self.Viewable.Lines, self.Viewable.Columns, self.Total.Lines, self.Total.Columns );
	if ( self:GetParent().Update ) then
		self:GetParent():Update( self.Viewable.Lines, self.Viewable.Columns, self.Total.Lines, self.Total.Columns, self.LineData );
	end
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

function PANEL:ApplySchemeSettings()
	derma.SkinHook( "Scheme", "TextEntry", self );
end

vgui.Register( "fileViewer_TextArea", PANEL, "Panel" );