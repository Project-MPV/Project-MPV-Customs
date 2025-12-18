--Luminent Crescent Dragon
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WYRM),1,1,Synchro.NonTuner(Card.IsAttribute,ATTRIBUTE_LIGHT),1,99)
	c:EnableReviveLimit()
	--Take control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.ttcon)
	e1:SetTarget(s.tttg)
	e1:SetOperation(s.ttop)
	c:RegisterEffect(e1)
	--Derease Level
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.ttcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_SYNCHRO),tp,LOCATION_MZONE,0,nil)
	return #g>1 and g:GetClassCount(Card.GetAttribute)>1
end
function s.tttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.tfilter,tp,0,LOCATION_ONFIELD,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,0,1,0,0)
end
function s.tfilter(c,tp)
	return c:GetSequence()<5 and
	(c:IsControler(1-tp) and c:IsControlerCanBeChanged()) or not c:IsMonster() and not c:IsStatus(STATUS_BATTLE_DESTROYED+STATUS_LEAVE_CONFIRMED)
end
function s.ttop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_SYNCHRO),tp,LOCATION_MZONE,0,nil)
	if #g>0 then
		local tc=Duel.SelectMatchingCard(tp,s.tfilter,tp,0,LOCATION_ONFIELD,1,1,nil,tp):GetFirst()
		if tc and tc:IsLocation(LOCATION_ONFIELD) then
			if tc:IsMonster() then
				 if Duel.GetControl(tc,tp,1)~=0 then
				 aux.DelayedOperation(tc,PHASE_END,id,e,tp,function(ag) Duel.SendtoHand(ag,e:GetOwner(),REASON_EFFECT) end,nil,0)
				 end
			else
				local loc=LOCATION_SZONE
				if tc:IsType(TYPE_FIELD) then
					loc=LOCATION_FZONE
				end
				if Duel.MoveToField(tc,tp,tp,loc,tc:GetPosition(),true)~=0 then
				aux.DelayedOperation(tc,PHASE_END,id,e,tp,function(ag) Duel.SendtoHand(ag,e:GetOwner(),REASON_EFFECT) end,nil,0)
				end
end
end
end
end

function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:HasLevel()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc~=c and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return c:GetLevel()>1
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,c) end
	local p=math.min(c:GetLevel()-1,6)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local lv=Duel.AnnounceLevel(tp,1,p)
	Duel.SetTargetParam(lv)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local ec=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,c)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=Duel.GetFirstTarget()
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:UpdateLevel(-lv,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)~=0 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:UpdateLevel(-lv,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,c)
		if ec:IsRelateToEffect(e) and ec:IsFaceup() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			if ec:IsHasEffect(EFFECT_ADD_ATTRIBUTE) and not ec:IsHasEffect(EFFECT_CHANGE_ATTRIBUTE) then
				e1:SetValue(ec:GetOriginalAttribute())
			else
				e1:SetValue(ec:GetAttribute())
			end
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			c:RegisterEffect(e1)
end
		end
	end
	if tc then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end

function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO)
end