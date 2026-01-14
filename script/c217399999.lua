--Eternity Ace - Chrono Nazark
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,false,false,16599999,1,s.ffilter,1)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--Shuffle banished "Eternity Tech" to debuff
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--PZ Effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.dpentg)
	e2:SetOperation(s.dpenop)
	c:RegisterEffect(e2)
	--To PZ
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.pencon)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
end
s.listed_names={16599999}
s.listed_series={0x993} 
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_XYZ)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,2,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function s.rmfilter(c)
	return c:IsSetCard(0x993) and c:IsAbleToDeck()
end
function s.afilter(c)
	return c:IsMonster() and c:IsFaceup() and (c:IsAttackAbove(0) or c:HasNonZeroAttack())
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.afilter,tp,0,LOCATION_MZONE,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_REMOVED,0,1,99,nil)
	local ct=Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	if ct==0 then return end
	local val=ct*600
	local og=Duel.GetMatchingGroup(s.afilter,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(og) do
	local prev_atk=tc:GetAttack()
	local newatk=math.max(prev_atk-val,0)
		--ATK down
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		--If ATK becomes 0
		if prev_atk>0 and newatk==0 then
			--Negate effects
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			tc:RegisterEffect(e3)
			--Cannot be battle target
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
			e4:SetValue(1)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e4)
			--But does not prevent you to attack
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_FIELD)
			e5:SetCode(EFFECT_DIRECT_ATTACK)
			e5:SetRange(LOCATION_MZONE)
			e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e5:SetTarget(s.dirtg)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
			tc:RegisterEffect(e5)
		end
	end
end
function s.dirfilter(c)
	return c:GetFlagEffect(id)==0
end
function s.dirtg(e,c)
	return not Duel.IsExistingMatchingCard(s.dirfilter,c:GetControler(),0,LOCATION_MZONE,1,nil)
end
function s.pendfilter(c)
	return c:IsMonster() and c:HasLevel() and c:IsFaceup()
end
function s.dpentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.pendfilter,tp,LOCATION_MZONE,0,nil)
		return aux.SelectUnselectGroup(g,e,tp,2,2,function(g) return g:GetSum(Card.GetLevel)==7 end,0) 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_PZONE)
end

function s.dpenop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.pendfilter,tp,LOCATION_MZONE,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,function(g) return g:GetSum(Card.GetLevel)==7 end,1,tp,HINTMSG_DESTROY)
	if #sg~=2 then return end
	if Duel.Destroy(sg,REASON_EFFECT)==2 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end