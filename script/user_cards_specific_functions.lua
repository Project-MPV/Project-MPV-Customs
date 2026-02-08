--Special Summon limit for "Darklight Fusion"-related Fusion monsters
function Auxiliary.DarkLightFLimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or se:GetHandler():IsCode(117106529)
end

if not GenerateEffect then
	GenerateEffect={}

	end
	--Additional ATTRIBUTE
	ATTRIBUTE_RADIANT= 0x100
	--Additional Types
	RACE_VIRTUOUS    = 0x8000000000000000