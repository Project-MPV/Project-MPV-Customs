--Blue-Eyes Ultimate Prophesied Dragon
function c303.initial_effect(c)
--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,200000301,3)
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsCode(),LOCATION_MZONE)
	--special summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
 	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
end

s.material_setcode=0xdd
s.listed_name={200000301}


function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),0,LOCATION_GRAVE,nil)*600
end

function s.filter(c)
	return c:IsSetCode(0xdd) or c:IsSetCode(0x776e) or c:IsSetCode(0x140) and (c:IsLocation(LOCATION_GRAVE)
end