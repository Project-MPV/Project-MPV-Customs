--Xtra HERO Neos Cosmos
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,2,nil)
	--extra summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x8))
	e1:SetValue(s.sumval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_EXTRA_SET_COUNT)
	c:RegisterEffect(e2)
	--HERO Backup
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetCondition(s.atkcon)
	e3:SetCost(s.atkcost)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
s.listed_series={0x8}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0x8,lc,sumtype,tp)
end
function s.sumval(e,c)
		local c=e:GetLabelObject() 
		local sumzone=e:GetHandler():GetLinkedZone()
		local relzone=-(1<<e:GetHandler():GetSequence())
		return 0,sumzone,relzone
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if a:IsControler(1-tp) then a,d=d,a end
	return a:IsSetCard(0x8) and a:IsRelateToBattle()
end
function s.filter2(c,e)
	return c:IsSetCard(0x8) and c:GetAttack()>0 and c:IsAbleToGraveAsCost() and not c:GetBattleTarget()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler():GetBattleTarget()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,e:GetHandler():GetBattleTarget())
	e:SetLabel(g1:GetFirst():GetAttack())
	Duel.SendtoGrave(g1,REASON_COST)
	e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.GetAttacker()
	if c:IsControler(1-tp) then c=Duel.GetAttackTarget() end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(e:GetLabel())
	c:RegisterEffect(e1)
end