local XX, w, h1, h2 = false, (WINDOW_W*0.4), (WINDOW_H*.32), (WINDOW_H*.8)
print("Streaming Loaded")


function OnTick()
	XX = IsKeyDown(9) and not IsKeyDown(18)
end
function OnDraw()
	if XX then
		DrawLine(w, h1, w, h2, 200, ARGB(255,0,0,0))
	end
end
