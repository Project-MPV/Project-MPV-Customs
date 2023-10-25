--Eureka Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0x7970),extrafil=s.extrafil,extraop=Fusion.BanishMaterial})
	c:RegisterEffect(e1)
end
s.listed_series={0x8,0x7970,0x7971}
function s.check(tp,sg,fc)
	return (function(c) return c:GetLocation()&~(LOCATION_ONFIELD) end)
end
function s.extrafil(e,tp,mg)
	return Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_EXTRA,0,nil),s.check
end

