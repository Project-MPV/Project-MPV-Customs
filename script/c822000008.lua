--Venom Apis
local s,id=GetID()
function s.initial_effect(c)
	--Normal/Special Summoned 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
s.listed_series={0x50}
s.counter_place_list={0x1009}
s.listed_names={8062132,72677437}
function s.esfilter(c)
	return (c:IsSetCard(0x50) and c:IsMonster() or c:IsCode(8062132,72677437) and c:IsAbleToHand())
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanAddCounter(0x1009,1)
end
function s.cfilter2(c)
	return c:IsSpellTrap()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local b1=Duel.IsExistingMatchingCard(s.esfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.GetFlagEffect(tp,id)==0
	local b2=Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) 
		and Duel.GetFlagEffect(tp,id+1)==0
	if chk==0 then return b1 or b2 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_COUNTER,nil,1,tp,LOCATION_MZONE)
end
function s.op(e,tp,eg,ep,ev,re,r,rp,g)
local b1=Duel.IsExistingMatchingCard(s.esfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.GetFlagEffect(tp,id)==0
local b2=Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) 
		and Duel.GetFlagEffect(tp,id+1)==0
	local op=0
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(id,0))
	elseif b2 then op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	else return end
if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.esfilter,tp,LOCATION_DECK,0,1,1,nil)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
	else
		if not Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil) then return end
		local g1=Duel.GetMatchingGroupCount(s.cfilter2,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
		local g2=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
  local g=Group.CreateGroup()
  local tc=g2:GetFirst()   
  for tc in aux.Next(g2) do
  local atk=tc:GetAttack()  
  tc:AddCounter(0x1009,g1)
  if atk>0 and tc:GetAttack()==0 then
  g:AddCard(tc)
  if #g>0 then
 	 Duel.RaiseEvent(tc,EVENT_CUSTOM+54306223,e,0,0,0,0)
 end
end
end
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
end
end
