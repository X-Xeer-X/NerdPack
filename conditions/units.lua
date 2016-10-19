local _, NeP = ...
local LibBoss = LibStub("LibBossIDs-1.0")
--[[
					UNITS CONDITIONS!
			Only submit UNITS specific conditions here.
					KEEP ORGANIZED AND CLEAN!

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
]]
NeP.DSL:Register("ingroup", function(target)
	return UnitInParty(target) or UnitInRaid(target)
end)

NeP.DSL:Register("group.members", function()
	return (GetNumGroupMembers() or 0)
end)

------------------------------------------ ANY -------------------------------------------
------------------------------------------------------------------------------------------

local UnitClsf = {
	['elite'] = 2,
	['rareelite'] = 3,
	['rare'] = 4,
	['worldboss'] = 5
}

NeP.DSL:Register('boss', function (target)
	local classification = UnitClassification(target)
	if UnitClsf[classification] then
		return UnitClsf[classification] >= 3
	end
	return LibBoss.BossIDs[NeP.Core:UnitID(target)] ~= nil
end)

NeP.DSL:Register('elite', function (target)
	local classification = UnitClassification(target)
	if UnitClsf[classification] then
		return UnitClsf[classification] >= 2
	end
	return LibBoss.BossIDs[NeP.Core:UnitID(target)] ~= nil
end)

NeP.DSL:Register("id", function(target, id)
	local expectedID = tonumber(id)
	return expectedID and NeP.Core:UnitID(target) == expectedID
end)

NeP.DSL:Register("threat", function(target)
	if UnitThreatSituation("player", target) then
		return select(3, UnitDetailedThreatSituation("player", target))
	end
	return 0
end)

NeP.DSL:Register("aggro", function(target)
	return (UnitThreatSituation(target) and UnitThreatSituation(target) >= 2)
end)

NeP.DSL:Register("moving", function(target)
	local speed, _ = GetUnitSpeed(target)
	return speed ~= 0
end)

NeP.DSL:Register("classification", function (target, spell)
	if not spell then return false end
	local classification = UnitClassification(target)
	if string.find(spell, '[%s,]+') then
		for classificationExpected in string.gmatch(spell, '%a+') do
			if classification == string.lower(classificationExpected) then
			return true
			end
		end
		return false
	else
		return UnitClassification(target) == string.lower(spell)
	end
end)

NeP.DSL:Register("target", function(target, spell)
	return ( UnitGUID(target .. "target") == UnitGUID(spell) )
end)

NeP.DSL:Register("player", function(target)
	return UnitIsPlayer(target)
end)

NeP.DSL:Register("isself", function(target)
	return UnitIsUnit(target, 'player')
end)

NeP.DSL:Register("exists", function(target)
	return (UnitExists(target))
end)

NeP.DSL:Register('dead', function (target)
	return UnitIsDeadOrGhost(target)
end)

NeP.DSL:Register("alive", function(target)
	return (UnitExists(target) and UnitHealth(target) > 0)
end)

NeP.DSL:Register("behind", function(target)
	return not NeP.Protected.Infront('player', target)
end)

NeP.DSL:Register("infront", function(target)
	return NeP.Protected.Infront('player', target)
end)

local movingCache = {}

NeP.DSL:Register("lastmoved", function(target)
	if UnitExists(target) then
		local guid = UnitGUID(target)
		if movingCache[guid] then
			local moving = (GetUnitSpeed(target) > 0)
			if not movingCache[guid].moving and moving then
				movingCache[guid].last = GetTime()
				movingCache[guid].moving = true
				return false
			elseif moving then
				return false
			elseif not moving then
				movingCache[guid].moving = false
				return GetTime() - movingCache[guid].last
			end
		else
			movingCache[guid] = { }
			movingCache[guid].last = GetTime()
			movingCache[guid].moving = (GetUnitSpeed(target) > 0)
			return false
		end
	end
	return false
end)

NeP.DSL:Register("movingfor", function(target)
	if UnitExists(target) then
		local guid = UnitGUID(target)
		if movingCache[guid] then
			local moving = (GetUnitSpeed(target) > 0)
			if not movingCache[guid].moving then
				movingCache[guid].last = GetTime()
				movingCache[guid].moving = (GetUnitSpeed(target) > 0)
				return false
			elseif moving then
				return GetTime() - movingCache[guid].last
			elseif not moving then
				movingCache[guid].moving = false
				return false
			end
		else
			movingCache[guid] = { }
			movingCache[guid].last = GetTime()
			movingCache[guid].moving = (GetUnitSpeed(target) > 0)
			return false
		end
	end
	return false
end)

NeP.DSL:Register("friend", function(target)
	return UnitExists(target) and not UnitCanAttack("player", target)
end)

NeP.DSL:Register("enemy", function(target)
	return UnitExists(target) and UnitCanAttack("player", target)
end)

NeP.DSL:Register("distance", function(target)
	return NeP.Protected.UnitCombatRange('player', target)
end)

NeP.DSL:Register("range", function(target)
	return NeP.DSL:Get("distance")(target)
end)

NeP.DSL:Register("level", function(target)
	return UnitLevel(target)
end)

NeP.DSL:Register("combat", function(target)
	return UnitAffectingCombat(target)
end)

NeP.DSL:Register("role", function(target, role)
	role = role:upper()
	local damageAliases = { "DAMAGE", "DPS", "DEEPS" }
	local targetRole = UnitGroupRolesAssigned(target)
	if targetRole == role then return true
	elseif role:find("HEAL") and targetRole == "HEALER" then
		return true
	else
		for i = 1, #damageAliases do
			if role == damageAliases[i] then
				return true
			end
		end
	end

	return false
end)

NeP.DSL:Register("name", function (target, expectedName)
	return UnitExists(target) and UnitName(target):lower():find(expectedName:lower()) ~= nil
end)

NeP.DSL:Register("creatureType", function (target, expectedType)
	return UnitCreatureType(target) == expectedType
end)

NeP.DSL:Register("class", function (target, expectedClass)
	local class, _, classID = UnitClass(target)
	if tonumber(expectedClass) then
		return tonumber(expectedClass) == classID
	else
		return expectedClass == class
	end
end)

NeP.DSL:Register("inMelee", function(target)
	return NeP.Protected.UnitCombatRange('player', target) <= 1.5
end)

NeP.DSL:Register("inRanged", function(target)
	return NeP.Protected.UnitCombatRange('player', target) <= 40
end)

NeP.DSL:Register("power.regen", function(target)
	return select(2, GetPowerRegen(target))
end)

NeP.DSL:Register("casttime", function(_, spell)
	return select(3, GetSpellInfo(spell))
end)

------------------------------------------ PLAYER ----------------------------------------
------------------------------------------------------------------------------------------

NeP.DSL:Register("ilevel", function()
	return math.floor(select(1,GetAverageItemLevel()))
end)

NeP.DSL:Register('swimming', function ()
	return IsSwimming()
end)

NeP.DSL:Register("lastcast", function(Unit, Spell)
	Spell = NeP.Spells:Convert(Spell)
	if UnitIsUnit('player', Unit) then
		local LastCast = NeP.Parser.LastCast
		return LastCast == Spell, LastCast
	end
	local LastCast = NeP.CombatTracker:LastCast(Unit)
	return LastCast == Spell, LastCast
end)

NeP.DSL:Register("mounted", function()
	return IsMounted()
end)

NeP.DSL:Register("enchant.mainhand", function()
	return (select(1, GetWeaponEnchantInfo()) == 1)
end)

NeP.DSL:Register("enchant.offhand", function()
	return (select(4, GetWeaponEnchantInfo()) == 1)
end)

NeP.DSL:Register("falling", function()
	return IsFalling()
end)

NeP.DSL:Register("deathin", function(target)
	return NeP.CombatTracker:TimeToDie(target)
end)

NeP.DSL:Register("ttd", function(target)
	return NeP.DSL:Get("deathin")(target)
end)

NeP.DSL:Register("charmed", function(target)
	return UnitIsCharmed(target)
end)

NeP.DSL:Register("glyph", function()
	local spellId = tonumber(spell)
	local glyphName, glyphId
	for i = 1, 6 do
		glyphId = select(4, GetGlyphSocketInfo(i))
		if glyphId then
			if spellId then
				if select(4, GetGlyphSocketInfo(i)) == spellId then
					return true
				end
			else
				glyphName = NeP.Core:GetSpellName(glyphId)
				if glyphName:find(spell) then
					return true
				end
			end
		end
	end
	return false
end)

NeP.DSL:Register('twohand', function()
	return IsEquippedItemType("Two-Hand")
end)

NeP.DSL:Register('onehand', function()
	return IsEquippedItemType("One-Hand")
end)

local communName = NeP.Locale:TA('Dummies', 'Name')
local matchs = NeP.Locale:TA('Dummies', 'Pattern')
NeP.DSL:Register('isdummy', function(unit)
	if not UnitExists(unit) then return end
	if UnitName(unit):lower():find(communName) then return true end
	return NeP.Tooltip:Unit(unit, matchs)
end)

------------------------------------------ OM CRAP ---------------------------------------
------------------------------------------------------------------------------------------
NeP.DSL:Register("area.enemies", function(unit, distance)
	local total = 0
	if not UnitExists(unit) then return total end
	for GUID, Obj in pairs(NeP.OM:Get('Enemy')) do
		if UnitExists(Obj.key) then
			local cdistance = NeP.Protected.Distance(unit, Obj.key) or 0
			if (NeP.DSL:Get('combat')(Obj.key) or Obj.isdummy) and cdistance <= tonumber(distance) then
				total = total +1
			end
		end
	end
	return total
end)

NeP.DSL:Register("area.friendly", function(unit, distance)
	local total = 0
	if not UnitExists(unit) then return total end
	for GUID, Obj in pairs(NeP.OM:GetRoster()) do
		if UnitExists(Obj.key) then
			local cdistance = NeP.Protected.Distance(unit, Obj.key) or 0
			if cdistance <= tonumber(distance) then
				total = total +1
			end
		end
	end
	return total
end)
