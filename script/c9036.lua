local s,id=GetID()
function s.initial_effect(c)
	--Normal Summoned 
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
--note:{aux.Stringid(id,0)== "Destroy"} and {aux.Stringid(id,1)== "Special Summon"} the string set become Topsy-Turvy, somehow....
function s.desfilter(c)
	return c:IsFacedown() and c:IsDestructable()
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) 
	else Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil)  end
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.op(e,tp,eg,ep,ev,re,r,rp,g)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e)then
		Duel.BreakEffect()
	if Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,0))==0 then
--Special Summon	
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
		else
--Destroy	
	local c=e:GetHandler()
	local sg=Duel.GetMatchingGroup(s.desfilter,1-tp,LOCATION_ONFIELD,nil,e)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=sg:Select(tp,2,2,nil)
			Duel.HintSelection(dg)
			Duel.Destroy(dg,REASON_EFFECT)

end
end
end
end