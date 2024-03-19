--Imaginary Force Enlighted
local s,id=GetID()
function s.initial_effect(c)
	--Targeted "Imaginary Force" monster cannot be destroyed, also neither player take battle damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	c:RegisterEffect(e1)
end
function s.sfilter(c)
	return c:IsSetCard(0x303) and c:IsLevelBelow(4) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x303) and c:IsLevelAbove(8)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,1,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Neither player take battle damage this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		--Cannot be destroyed
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(3000)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetDescription(3001)
		e3:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetValue(1)
		tc:RegisterEffect(e3)
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetCode(EFFECT_ATTACK_ALL)
		e4:SetValue(1)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e4)
		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e5:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
		e5:SetCondition(s.tgcon)
		e5:SetTarget(s.tgtg)
		e5:SetOperation(s.tgop)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e5)
	end
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local d=c:GetBattleTarget()
	e:SetLabelObject(d)
	return c==Duel.GetAttacker() and d and d:IsOnField() and d:IsRelateToBattle()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetLabelObject(),1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
		local d=e:GetLabelObject()
		if d:IsRelateToBattle() and d:IsControler(1-tp) then
		if Duel.SetLP(1-tp,Duel.GetLP(1-tp)-800)~=0 then
		Duel.SendtoDeck(d,nil,1,REASON_EFFECT)			
		end
	end
end
