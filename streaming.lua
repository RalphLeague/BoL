local w, h1, h2 = (WINDOW_W*0.4), (WINDOW_H*.32), (WINDOW_H*.8)
print("Streaming Loaded")

function OnTick()
	if IsKeyDown(9) and not IsKeyDown(18) then
		Draw = function() DrawLine(w, h1, w, h2, 200, ARGB(255,0,0,0)) end
	else
		Draw = function() end
	end
end

function Draw()
end

AddDrawCallback(function() Draw() end)
