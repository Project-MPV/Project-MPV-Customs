--Eternity Ace - Chaos Matter
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.ffilter1,s.ffilter2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--Halve all damage
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.hvcost)
	e1:SetCountLimit(1)
	e1:SetOperation(s.hvop)
	c:RegisterEffect(e1)
end
function s.ffilter1(c,fc,sumtype,tp)
	return c:IsSetCard(0x994) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.ffilter2(c,fc,sumtype,tp)
	return c:IsSetCard(0x994) and c:IsAttribute(ATTRIBUTE_DARK) 
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost() end,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function s.filter(c)
	return c:IsCanChangePosition() and c:IsControler(1-tp)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x993) and c:IsAbleToRemoveAsCost() 
end
function s.hvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.hvop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.val1)
	e1:SetReset(RESET_PHASE+PHASE_END,1)
	Duel.RegisterEffect(e1,tp)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end	
end
function s.val1(e,re,dam,r,rp,rc)
	if r&(REASON_BATTLE+REASON_EFFECT)~=0 then
		return dam/2
	else return dam end
end
