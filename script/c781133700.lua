--Breeze Synchro Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(s.ffilter),nil,s.fextra,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil)
	e1:SetCondition(s.condition)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()&PHASE_MAIN1+PHASE_MAIN2>0
end
function s.ffilter(c)
	return (c:IsAttribute(ATTRIBUTE_WATER) or c:IsAttribute(ATTRIBUTE_WIND))
end
function s.synfilter(c)
	return c:IsType(TYPE_SYNCHRO)
end
function s.exfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EXTRA)
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)&~(LOCATION_ONFIELD)<=1 
end
function s.fextra(e,tp,mg)
	if Duel.GetMatchingGroupCount(s.exfilter,tp,0,LOCATION_MZONE,nil)>0 and Duel.GetMatchingGroupCount(s.exfilter,tp,LOCATION_MZONE,0,nil)>0 then
	return Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,LOCATION_MZONE,nil,TYPE_SYNCHRO),s.fcheck 
end
	return nil
end

