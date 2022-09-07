--2's Knight
local s,id=GetID()
function c200009371.initial_effect(c)
--PendulumSummon
	Pendulum.AddProcedure(c)
--When in the PZone: all "'s Knight" on Field gains 400 ATK for each "'s Knight" on Field or in GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e2)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsSetCard,0x7771),c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,s.filter)*400
end
function s.filter(c,e,tp)
	return c:IsSetCode(0x7771) and c:IsLocation(LOCATION_ONFIELD) and c:IsLocation(LOCATION_GRAVE)
end