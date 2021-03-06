local _, NeP = ...

NeP.OM = {}

local OM_c = {
	Enemy = {},
	Friendly = {},
	Dead = {}
}

function NeP.OM:Garbage()
	for tb in pairs(OM_c) do
		for GUID, obj in pairs(OM_c[tb]) do
			if not UnitExists(obj.key) then
				OM_c[tb][GUID] = nil
			elseif tb ~= 'Dead' and UnitIsDeadOrGhost(obj.key) then
				OM_c[tb][GUID] = nil
			end
		end
	end
end

function NeP.OM:Get(ref)
	return OM_c[ref]
end

function NeP.OM:Filter(ref, GUID)
	local obj = OM_c[ref][GUID]
	if not obj or not UnitExists(obj.key) then return end
	obj.distance = NeP.Protected.Distance('player', obj.key)
	return true
end

function NeP.OM:Insert(ref, Obj)
	local GUID = UnitGUID(Obj) or '0'
	if self:Filter(ref, GUID) then return end
	local ObjID = select(6, strsplit('-', GUID))
	local distance = NeP.Protected.Distance('player', Obj)
	OM_c[ref][GUID] = {
		key = Obj,
		name = UnitName(Obj),
		distance = distance,
		id = tonumber(ObjID) or '0',
		guid = GUID,
		isdummy = NeP.DSL:Get('isdummy')(Obj)
	}
end

function NeP.OM:Add(Obj)
	if not UnitExists(Obj) then return end
	-- Dead Units
	if UnitIsDeadOrGhost(Obj) then
		NeP.OM:Insert('Dead', Obj)
	-- Friendly
	elseif UnitIsFriend('player', Obj) then
		NeP.OM:Insert('Friendly', Obj)
	-- Enemie
	elseif UnitCanAttack('player', Obj) then
		NeP.OM:Insert('Enemy', Obj)
	end
end

C_Timer.NewTicker(1, (function()
	NeP.OM.Maker()
	NeP.OM.Garbage()
end), nil)

-- Gobals
NeP.Globals.OM = {
	Add = NeP.OM.Add,
	Get = NeP.OM.Get
}
