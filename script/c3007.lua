--Marvelous HERO Tech Bel
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--add
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(s.tstg)
	e1:SetOperation(s.tsop)
	c:RegisterEffect(e1)
		aux.GlobalCheck(s,function()
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetOperation(s.checkop)
		Duel.RegisterEffect(ge2,0)
	end)
end
s.listed_series={0x7971,0x7970,0x8}
function s.cfilter(c)
	local seq=c:GetSequence()
	return c:GetFlagEffect(id+seq)==0 and (not c:IsPreviousLocation(LOCATION_PZONE) or c:GetPreviousSequence()~=seq)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tot=Duel.IsDuelType(DUEL_SEPARATE_PZONE) and 13 or 4
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_PZONE,LOCATION_PZONE,nil)
	if #g>0 then
		for tc in aux.Next(g) do
			tc:ResetFlagEffect(id+tot-tc:GetSequence())
			Duel.RaiseSingleEvent(tc,EVENT_CUSTOM+id,e,0,tp,tp,0)
			tc:RegisterFlagEffect(id+tc:GetSequence(),RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end
end
function s.filter(c)
	return c:IsSetCard(0x8) and c:IsLevelBelow(5) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.tstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
end
function s.tsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end