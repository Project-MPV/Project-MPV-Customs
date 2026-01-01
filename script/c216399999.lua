--Eternity Tech - Time Leap
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Banish 1 "Eternity Ace"; SS different Attribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--If this card is banished: Rank-Up Xyz
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
s.listed_series={0x994}
function s.costfilter(c)
	return c:IsSetCard(0x994) and c:IsMonster()
		and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
		and c:IsAbleToRemoveAsCost()
end
function s.spfilter(c,e,tp,att)
	return c:IsSetCard(0x994) and c:IsMonster()
		and c:GetOriginalAttribute()~=att
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local att=g:GetFirst():GetOriginalAttribute()
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(att)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local att=e:GetLabel()
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,att) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local att=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,att)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.xyzmatfilter(c)
	return (c:IsSetCard(0x994) and c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED))
	or (c:IsPendulumMonster() and c:IsFaceup() and c:IsLocation(LOCATION_EXTRA))
end
function s.xyzspfilter(c,e,tp,rank)
	return c:IsType(TYPE_XYZ) and c:IsRace(RACE_CYBERSE)
		and (c:GetRank()==rank+1 or c:GetRank()==rank+2)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzmatfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,1,nil)end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local mg=Duel.SelectMatchingCard(tp,s.xyzmatfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,1,1,nil)
	local mc=mg:GetFirst()
	if not mc then return end
	local rank=mc:GetRank()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.xyzspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,rank)
	local sc=sg:GetFirst()
	if not sc then return end
	sc:SetMaterial(Group.FromCards(mc))
	Duel.Overlay(sc,Group.FromCards(mc))
	if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()
	end
end
