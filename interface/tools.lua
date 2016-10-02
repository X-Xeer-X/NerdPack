NeP.Interface = {}

function NeP.Interface:NewFrame(eval)
	local position = {'CENTER', 0, 0}
	if eval.loc then position = eval.loc end
	local temp = CreateFrame("Frame", nil, (eval.parent or UIParent))
	temp:SetPoint(unpack(position))
	temp:SetSize(unpack(eval.size))
	temp:SetMovable(true)
	temp:SetFrameLevel(0)
	temp:SetClampedToScreen(true)
	
	temp.border = temp:CreateTexture(nil,"BACKGROUND")
	temp.border:SetColorTexture(0,0,0,1)
	temp.border:SetPoint("TOPLEFT",-2,2)
	temp.border:SetPoint("BOTTOMRIGHT",2,-2)
	temp.border:SetVertexColor(0.85,0.85,0.85,1) -- half-alpha light grey

	temp.body = temp:CreateTexture(nil,"ARTWORK")
	temp.body:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	temp.body:SetAllPoints(temp)
	temp.body:SetVertexColor(0.1,0.1,0.1,1) -- solid dark grey

	return temp
end

function NeP.Interface:AddText(parent, text)
	local temp = parent:CreateFontString()
	temp:SetFont("Fonts\\FRIZQT__.TTF", 16)
	temp:SetShadowColor(0,0,0, 0.8)
	temp:SetShadowOffset(-1,-1)
	temp:SetPoint("CENTER", parent)
	temp:SetText(text)
	return temp
end

function NeP.Interface:Tittlebar(parent, text)
	local temp = self:NewFrame({
		color = {0,0,0,0.9},
		size = {parent:GetWidth(), 20},
		loc = {'TOP'},
		parent = parent,
	})
	temp.text = self:AddText(temp, text)
	temp:EnableMouse(true)
	temp:RegisterForDrag('LeftButton', 'RightButton')
	temp:SetScript('OnDragStart', function() parent:StartMoving() end)
	temp:SetScript('OnDragStop', function() parent:StopMovingOrSizing() end)
	return temp
end

function NeP.Interface:BuildGUI(eval)
	local temp = self:NewFrame(eval)
	local tSize = 0
	if eval.title then
		temp.title = self:Tittlebar(temp, eval.title)
		tSize = temp.title:GetHeight()
	end
	temp.content = self:NewFrame({
		color = {0,0,0,0},
		size = {temp:GetWidth()-4, temp:GetHeight()-tSize},
		loc = {'TOP', 0, -tSize},
		parent = temp,
	})
	return temp
end