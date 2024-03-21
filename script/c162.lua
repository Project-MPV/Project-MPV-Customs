--Yubel - The Nightmare Reborn
Duel.LoadScript("c420.lua") --DON'T ERASE THIS!
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,s.ffilter,2,2,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_YUBEL))
	--special summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--Cannot be destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	--Reflect Battle Damage
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e4:SetCondition(s.condition)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--Fusion summon
	local e5=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x8),Fusion.OnFieldMat,s.fextra)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.spcon)
	e5:SetCountLimit(1,id)
	c:RegisterEffect(e5)
end
s.listed_names={78371393}
s.material_setcode={0x8,0x3008,0x9,0x561}
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsSetCard(0x8,fc,sumtype,tp) and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,sumtype,tp))
end
function s.fusfilter(c,code,fc,sumtype,tp)
	return c:IsSummonCode(fc,sumtype,tp,code) and not c:IsHasEffect(511002961)
end
function s.condition(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x3008),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler()) 
end
function s.sfilter(c)
	return c:IsType(TYPE_FUSION)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup),tp,0,LOCATION_ONFIELD,nil)
	
end