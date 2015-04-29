--[[
	File Browser 2.0
	by Ryan 'Joudoki' Lewellen
	June 9th, 2008 - June 24th, 2008
--]]

fileBrowser.fileLibrary = {};

function fileBrowser.fileLibrary.getList( folder, filter )
	print(folder,filter)
	local files, folders = file.Find( folder .. filter,"DATA" );
	if not files then
		return {}
	end
	table.sort( files );
	local fileData = {};
	for k,v in pairs( files ) do
		local fl = {};
		fl.raw = v;
		fl.path = folder;
		fl.ext = string.GetExtensionFromFilename( v );
		if ( fl.ext=="" ) then
			fl.dir = file.IsDir( folder .. v );
			fl.name = v;
		else
			fl.dir = false;
			fl.name = string.gsub( v, "%." .. fl.ext, "" );
		end
		if ( fl.dir == false ) then
			fileData[ k ] = fl;
		end
	end
	return fileData;
end

-- This function is meant to be called recursively
function fileBrowser.fileLibrary.Search( folder, filter, subFolders, iteration )
	local tabs = "";
	local iter = iteration or 0;
	for i=1, iter do 
		tabs = tabs .. "\t";
	end
	
	-- This is where the results go
	local fileData = {};
	
	print( tabs .. folder .. filter );
	
	-- Find files in this folder first
	fileData = fileBrowser.fileLibrary.getList( folder, filter );
	
	-- Find folders
	if ( subFolders == true ) then
		local files, folders = file.Find( folder .. "*","DATA" );
		if not folders then
			return {}
		end
		for k,v in pairs( folders ) do
			local searchFolder = folder .. v .. "/";
			local result = fileBrowser.fileLibrary.Search( searchFolder, filter, true, iter + 1 );
			local offset = #fileData;
			
			for num,res in pairs( result ) do
				fileData[ num + offset ] = res;
			end
		end
	end
	
	return fileData;
end