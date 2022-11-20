--Dichroic Assault Striker
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,537610001,s.ffilter)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--odd destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
function s.ffilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_WARRIOR,fc,sumtype,tp) and c:GetLevel()<=4
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	local g=Group.CreateGroup()
	if tc:GetBaseAttack()~=tc:GetAttack() then
		g:AddCard(tc)
	end
	if bc:GetBaseAttack()~=bc:GetAttack() then
		g:AddCard(bc)
	end
	g:KeepAlive()
	e:SetLabelObject(g)
	return #g>0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject()
	if chk==0 then return g and g:IsExists(Card.IsDestructable,1,nil) end
	g:KeepAlive()
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desfilter(c)
	return c:IsRelateToBattle() and c:GetBaseAttack()~=c:GetAttack()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():Filter(s.desfilter,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:IsType(TYPE_MONSTER)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT)) and not c:IsReason(REASON_REPLACE)
end
function s.dsfilter(c,e,tp)
	return (c:IsControler(tp) or c:IsControler(1-tp)) and c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_MONSTER)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.dsfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,s.dsfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
