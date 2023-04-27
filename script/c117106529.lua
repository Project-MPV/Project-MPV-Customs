--Darklight Fusion
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,s.ffilter,Fusion.OnFieldMat(Card.IsAbleToRemove),s.fextra,Fusion.BanishMaterial,nil,s.stage2)
	e1:SetCost(s.cost)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	local tg=e1:GetTarget()
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then
						return tg(e,tp,eg,ep,ev,re,r,rp,chk)
					end
					tg(e,tp,eg,ep,ev,re,r,rp,chk)
					if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
						Duel.SetChainLimit(aux.FALSE)
					end
				end)
	c:RegisterEffect(e1)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
end
function s.ffilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_WYRM)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,LOCATION_ONFIELD,0,nil)
	end
	return nil
end
function s.spfilter(c)
	return c:IsSetCard(0x46) or c:IsCode(8855578) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1500) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	Duel.PayLPCost(tp,1500)
end
function s.stage2(e,tc,tp,sg,chk)
if chk==1 then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(s.cfilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.cfilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
