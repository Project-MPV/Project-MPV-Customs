--Dragonic Phantasm Curse
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(s.equipfilter))
	--indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_INDESTRUCTABLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.cfcost)
	e2:SetTarget(s.cftg)
	e2:SetOperation(s.cfop)
	c:RegisterEffect(e2)
end
s.listed_names={0x145}
function s.equipfilter(c)
	return c:IsSetCard(0x145) and c:IsRace(RACE_WYRM) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.cfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipTarget():GetAttackAnnouncedCount()==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
function s.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
end
function s.cfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
	Duel.HintSelection(g)
	local tc=g:GetFirst()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
	Duel.AdjustInstantly(c)
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end
end