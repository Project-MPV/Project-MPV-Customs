--Dark Templar Dragon
--scripted by Fawwazzed
Duel.LoadScript("user_cards_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
c:SetUniqueOnField(1,0,id)
Auxiliary.addLizardCheck(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcFun2(c,s.ffilter1,s.ffilter,true)
	--Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(aux.DarkLightFLimit)
	c:RegisterEffect(e1)
	--copy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.copycon)
	e2:SetTarget(s.copytg)
	e2:SetOperation(s.copyop)
	c:RegisterEffect(e2)
	--Choose a Chain to negate and copy operation of that effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL|EFFECT_FLAG_NO_TURN_RESET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.negcon)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
s.listed_names={117106529}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)
end
function s.ffilter1(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
function s.copycon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsNegatableMonster() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		Duel.AdjustInstantly(c)
		Duel.SendtoGrave(tc,REASON_EFFECT)
		c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD,1)
end
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()>0
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local function valid_chain(ch_index)
		local te=Duel.GetChainInfo(ch_index,CHAININFO_TRIGGERING_EFFECT)
		if not te or not te:IsActiveType(TYPE_MONSTER) or not Duel.IsChainNegatable(ch_index) then 
			return false 
		end
		local tc=te:GetHandler()
		return tc~=c and te:GetHandler()~=c
	end
	if chk==0 then
		for i=1,ev do
			if valid_chain(i) then return true end
		end
		return false
	end
	local t={}
	for i=1,ev do
		if valid_chain(i) then
			table.insert(t,i)
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local sel=Duel.AnnounceNumber(tp,table.unpack(t))
	e:SetLabel(sel)	
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel_ev=e:GetLabel()
	if sel_ev<=0 then return end	
	local te=Duel.GetChainInfo(sel_ev,CHAININFO_TRIGGERING_EFFECT)
	if not te then return end		
	--NEGATE ACTIVATION ON CHAIN
	if Duel.NegateActivation(sel_ev) then	
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			Duel.BreakEffect()				
			local stolen_e=te:Clone()
			local copied_tg=te:GetTarget()
			local copied_op=te:GetOperation()
			--Use the copy effect count limit
			local count,code=te:GetCountLimit()			
			--STOLEN EFFECT REGISTER TO DARK TEMPLAR
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_QUICK_O)
			e1:SetCode(EVENT_FREE_CHAIN)
			e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
			e1:SetRange(LOCATION_MZONE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			if count>0 then
				--copy count limit
				if code>0 then
					e1:SetCountLimit(count,{id,1})
				else
					e1:SetCountLimit(count)
				end
			end			
			e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
				if chkc then
					if copied_tg then
						return copied_tg(stolen_e,tp,eg,ep,ev,re,r,rp,chk,chkc)
					end
					return false
				end
				if chk==0 then
					if copied_tg then
						return copied_tg(stolen_e,tp,eg,ep,ev,re,r,rp,0)
					end
					return true
				end
				if copied_tg then
					copied_tg(stolen_e,tp,eg,ep,ev,re,r,rp,1)
				end
			end)		
			e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
				if copied_op then
					copied_op(stolen_e,tp,eg,ep,ev,re,r,rp)
				end
			end)					
			c:RegisterEffect(e1)
			Duel.Hint(HINT_CARD,0,te:GetHandler():GetOriginalCode())
		end
	end
end