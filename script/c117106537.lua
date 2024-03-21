--Void King Endroga
Duel.LoadScript("user_cards_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	c:SetSPSummonOnce(id)
	Auxiliary.addLizardCheck(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcFun2(c,s.ffilter,s.ffilter1,true)
	--cannot be summon material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(aux.DarkLightFLimit)
	c:RegisterEffect(e1)
	--Check materials used for its fusion summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	c:RegisterEffect(e2)
	--Gains various effects, based on card types used for its fusion summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.regcon)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	e3:SetLabelObject(e2)
	
end
s.listed_names={117106529}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsCode(117106536)
end
function s.ffilter1(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end

function s.matfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if not g then return end
	local typ=0
	for tc in aux.Next(g) do
		typ=(typ|tc:GetType())
	end
	typ=(typ&TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	e:SetLabel(typ)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabelObject():GetLabel()~=0
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local typ=e:GetLabelObject():GetLabel()
	local c=e:GetHandler()
	if (typ&TYPE_FUSION)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetTarget(s.distg)
		e1:SetOperation(s.disop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
	end
	if (typ&TYPE_SYNCHRO)~=0 then
		--destroy & damage
		local e2=Effect.CreateEffect(c)
		e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_SUMMON_SUCCESS)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCountLimit(1)
		e2:SetTarget(s.damtg)
		e2:SetOperation(s.damop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		local e4=e2:Clone()
		e4:SetCode(EVENT_SPSUMMON_SUCCESS)
		c:RegisterEffect(e4)
		local e5=e2:Clone()
		e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		c:RegisterEffect(e5)
		local e6=e2:Clone()
		e6:SetCode(EVENT_MSET)
		c:RegisterEffect(e6)
		local e7=e2:Clone()
		e7:SetCode(EVENT_CHANGE_POS)
		c:RegisterEffect(e7)
		local e9=e2:Clone()
		e9:SetCode(EVENT_SSET)
		c:RegisterEffect(e9)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
	if (typ&TYPE_XYZ)~=0 then
		local e3=Effect.CreateEffect(c)
		e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetRange(LOCATION_MZONE)
		e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetTarget(s.aatg)
		e3:SetValue(0)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
		local e8=e3:Clone()
		e8:SetCode(EFFECT_SET_DEFENSE_FINAL)
		c:RegisterEffect(e8)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
	end
end
function s.disfilter(c)
	return c:IsFaceup() and not c:IsDisabled()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_MZONE)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Destroy(g,REASON_EFFECT)	
	end
end
end
function s.dfilter(c,e,sp,p)
	return c:IsFacedown() or c:GetSummonPlayer()==sp  and (not e or c:IsRelateToEffect(e)) 
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.dfilter,1,nil,nil,1-tp) end
	local g=eg:Filter(s.dfilter,nil,nil,1-tp)
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.dfilter,nil,e,1-tp)
	if e:GetHandler():IsRelateToEffect(e) and #g~=0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
function s.aatg(e,c)
	return c==e:GetHandler():GetBattleTarget()
end