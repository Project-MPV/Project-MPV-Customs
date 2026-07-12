--Enigmation Burst Charge
local s,id=GetID()
function s.initial_effect(c)
	--Banish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--Destroy S/T
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.stcost)
	e2:SetTarget(s.sttg)
	e2:SetOperation(s.stop)
	c:RegisterEffect(e2)
end
s.listed_series={0x344}
function s.nope(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) 
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x344),tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
    if chk==0 then return #g>0 end
   Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local c=e:GetHandler()
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
        Duel.HintSelection(g,true)
        if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
            --then if you control no Fusion, Synchro or Xyz monster
            if not Duel.IsExistingMatchingCard(s.nope,tp,LOCATION_MZONE,0,1,c) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
                local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,0,1,1,c)
                if #rg>0 then
                    Duel.HintSelection(rg)
                    Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
                end
            end
        end
    end
end

function s.cfilter(c)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and c:IsAbleToExtraAsCost()
end

function s.stcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(c)
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	Duel.SendtoDeck(g:Filter(Card.IsLocation,nil,LOCATION_GRAVE),nil,SEQ_DECKBOTTOM,REASON_COST)
end

function s.sop(c)
	return c:IsSpellTrap()
end

function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.sop,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    local g=Duel.GetMatchingGroup(s.sop,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.stop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.sop,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
        Duel.HintSelection(g)
        Duel.Destroy(g,REASON_EFFECT)
    end
end