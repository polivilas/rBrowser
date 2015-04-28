--[[
	File Browser 2.0
	by Ryan 'Joudoki' Lewellen
	June 9th, 2008 - June 24th, 2008
--]]

-- For reading text or lua files
soundPlayer = {};
soundPlayer.Players = {};

function soundPlayer.Create( fData )
	if ( !fData ) then
		return false end
		
	print( "Opening sound file in reader: [" .. fData.path .. fData.name .. "." .. fData.ext .. "]" );
		
	local id = table.getn( soundPlayer.Players ) + 1;
	
	local sPlayer = vgui.Create( "DFrame" );
		sPlayer:SetSize( 300,210 );
		sPlayer:Center();
		sPlayer:SetTitle( tostring( fData.name ) .. "." .. tostring( fData.ext ) );
		sPlayer:SetVisible( true );
		sPlayer:SetDraggable( true );
		sPlayer:ShowCloseButton( true );
		sPlayer:MakePopup();
		
	local contentPanel = vgui.Create( "DPanelList", sPlayer );
		contentPanel:SetSize( 280, 170 );
		contentPanel:SetPos( 10, 30 );
		contentPanel:SetPadding( 10 );
		contentPanel:SetSpacing( 10 );
		
	local playButton = vgui.Create( "DButton", sPlayer );
		playButton:SetText( "Play" );
		playButton.playerID = id;
		playButton.DoClick = soundPlayer.Play;
		contentPanel:AddItem( playButton );
		
	local stopButton = vgui.Create( "DButton", sPlayer );
		stopButton:SetText( "Stop" );
		--stopButton:SetPos( 110,30 );
		stopButton.playerID = id;
		stopButton.DoClick = soundPlayer.Stop;
		contentPanel:AddItem( stopButton );
		
	local pitchSlider = vgui.Create( "DNumSlider", sPlayer )
		--pitchSlider:SetPos( 10,60 );
		--pitchSlider:SetSize( 100, 100 );
		pitchSlider:SetText( "Pitch" );
		pitchSlider:SetMin( 1 );
		pitchSlider:SetValue( 100 );
		pitchSlider:SetMax( 255 );
		pitchSlider:SetDecimals( 1 );
		pitchSlider.playerID = id;
		pitchSlider.OnValueChanged = soundPlayer.ChangePitch;
		contentPanel:AddItem( pitchSlider );
	
	local volumeSlider = vgui.Create( "DNumSlider", sPlayer )
		--volumeSlider:SetPos( 120,60 );
		--volumeSlider:SetSize( 100, 100 );
		volumeSlider:SetText( "Volume" );
		volumeSlider:SetMin( 0 );
		volumeSlider:SetMax( 2 );
		volumeSlider:SetValue( 1 );
		volumeSlider:SetDecimals( 3 );
		volumeSlider.playerID = id;
		volumeSlider.OnValueChanged = soundPlayer.ChangeVolume;
		contentPanel:AddItem( volumeSlider );
		
	sPlayer.Play = playButton;
	sPlayer.Stop = stopButton;
	
	sPlayer.Pitch = pitchSlider;
	sPlayer.pitch = 100;
	
	sPlayer.Volume = volumeSlider;
	sPlayer.volume = 1;
	
	sPlayer.soundPath = string.gsub( fData.path .. fData.name .. "." .. fData.ext, "../sound/", "" );
	
	sPlayer.Sound = CreateSound( LocalPlayer(), sPlayer.soundPath );
	sPlayer.Sound:Play();
	
	-- Make sure that when the window closes, the sound stops
	sPlayer.btnClose.DoClick = function()
		if ( fileBrowser.Settings.GetSetting( "sound_stopplayonclose" ) == true ) then
			sPlayer.Sound:Stop();
		end
		sPlayer:Close();		
	end
	
	soundPlayer.Players[id] = sPlayer;
	return id;
end
function soundPlayer.Remove( ID )
	if ( soundPlayer.Players[ ID ] ) then
		soundPlayer.Players[ ID ]:Remove();
	end
end

function soundPlayer.Play( button )
	--print( "Playing sound! [" .. button.playerID .. "][" .. tostring( soundPlayer.Players[ button.playerID ].Sound ) .. "]" );
	soundPlayer.Players[ button.playerID ].Sound:Stop();
	soundPlayer.Players[ button.playerID ].Sound:PlayEx( soundPlayer.Players[ button.playerID ].volume, soundPlayer.Players[ button.playerID ].pitch );
end
function soundPlayer.Stop( button )
	soundPlayer.Players[ button.playerID ].Sound:Stop();
end
function soundPlayer.ChangePitch( slider, pitch )
	soundPlayer.Players[ slider.playerID ].Sound:ChangePitch( pitch );
	soundPlayer.Players[ slider.playerID ].pitch = pitch;
end
function soundPlayer.ChangeVolume( slider, volume )
	soundPlayer.Players[ slider.playerID ].Sound:ChangeVolume( volume );
	soundPlayer.Players[ slider.playerID ].volume = volume;
end

function soundPlayer.MakeSettingsPanel()
	local settings = fileBrowser.Settings.AddSheet( "Sound Player", "rbrowser/file_audio.vmt", "Sound Player Settings" );
	fileBrowser.Settings.AddOption( settings, "checkbox", "Stop Sounds on Close",  "sound_stopplayonclose", true );
end