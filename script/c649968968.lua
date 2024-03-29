--Exfrost Shard Blast
Duel.EnableUnofficialProc(PROC_STATS_CHANGED)
Duel.LoadScript("c511000883.lua")
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_DRAW_PHASE)
	c:RegisterEffect(e1)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCode(511000883)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
s.listed_series={0xfc13}
s.listed_names={749968950}
function s.cfilter(c,tp)
	local val=0
	if c:GetFlagEffect(284)>0 then val=c:GetFlagEffectLabel(284) end
	return c:IsControler(tp) and c:GetAttack()~=val and c:IsAttribute(ATTRIBUTE_WATER)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.diffilter1(c,g)
	local dif=0
	local val=0
	if c:GetFlagEffect(284)>0 then val=c:GetFlagEffectLabel(284) end
	if c:GetAttack()>val then dif=c:GetAttack()-val
	else dif=val-c:GetAttack() end
	return g:IsExists(s.diffilter2,1,c,dif)
end
function s.diffilter2(c,dif)
	local dif2=0
	local val=0
	if c:GetFlagEffect(284)>0 then val=c:GetFlagEffectLabel(284) end
	if c:GetAttack()>val then dif2=c:GetAttack()-val
	else dif2=val-c:GetAttack() end
	return dif~=dif2
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.HasNonZeroAttack,tp,0,LOCATION_MZONE,1,nil) end
	local ec=eg:GetFirst()
	local g=eg:Filter(s.diffilter1,nil,eg)
	local g2=Group.CreateGroup()
	if #g>0 then g2=g:Select(tp,1,1,nil) ec=g2:GetFirst() end
	if #g2>0 then Duel.HintSelection(g2) end
	local dam=0
	local val=0
	if ec:GetFlagEffect(284)>0 then val=ec:GetFlagEffectLabel(284) end
	if ec:GetAttack()>val then dam=ec:GetAttack()-val
	else dam=val-ec:GetAttack() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.HasNonZeroAttack,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetTargetParam(dam)
end
function s.fycon1(c)
	return c:IsFaceup() and c:IsSetCard(0xfc13) and c:IsMonster()
end
function s.fycon2(c)
	return c:IsFaceup() and c:IsCode(749968950)
end
function s.negfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup() and not c:IsDisabled()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local cck1=Duel.IsExistingMatchingCard(s.fycon1,tp,LOCATION_MZONE,0,1,nil)
	local cck2=Duel.IsExistingMatchingCard(s.fycon2,tp,LOCATION_MZONE,0,1,nil)
	local atk=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-atk)
		tc:RegisterEffect(e1)
		if cck1 then
		if Duel.Damage(1-tp,atk,REASON_EFFECT)~=0 then
		if cck2 and Duel.IsExistingMatchingCard(s.negfilter,tp,0,LOCATION_ONFIELD,1,nil) then
		local kk=Duel.SelectMatchingCard(tp,s.negfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #kk>0 then
		Duel.HintSelection(kk)
		local rk=kk:GetFirst()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		rk:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rk:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rk:RegisterEffect(e3)
end
end		
end
end
end
end