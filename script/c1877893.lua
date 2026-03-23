--Inferno Rebirth Dragon (Grade 10)
--scripted by fawwazzed
if not PROC_REBIRTH_LOADED then Duel.LoadScript("proc_rebirth.lua") end
if not MPV_CONSTANTS_IMPORTED then Duel.LoadScript("MPV_constant.lua") end
local s,id=GetID()
s.Rebirth=true
function s.initial_effect(c)
    c:EnableReviveLimit()  
    --GENERIC REBIRTH PROCEDURE
    Rebirth.AddGenericProcedure(c,2,99,s.matfilter,10)
    --ATK (Material)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)
	--Soul Barrier (Protect your card for being destroyed)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(s.reptg)
    e2:SetValue(s.repval)
    e2:SetOperation(s.repop)
    c:RegisterEffect(e2)
	--Destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end

function s.matfilter(tc)
    return tc:IsAttribute(ATTRIBUTE_FIRE) and tc:IsHasEffect(EFFECT_REBIRTH_GRADE)
end

--ATK+ for each material stacked
function s.atkval(e,c)
    return c:GetOverlayCount()*1000
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return eg:IsExists(Card.IsControler,1,nil,tp) and eg:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD)
        and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
    return Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,0))
end

function s.repval(e,c)
    return c:IsControler(e:GetHandlerPlayer()) and c:IsLocation(LOCATION_ONFIELD)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    --Shuffle Soul Material from this card instead
    local g=c:GetOverlayGroup()
    if #g>0 then
        local sg=g:Select(tp,1,1,nil)
        if #sg>0 then
            Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
        end
    end
end

function s.spfilter(tc,e,tp)
    return tc:IsHasEffect(EFFECT_REBIRTH_GRADE) 
        and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_GRAVE)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
        Duel.HintSelection(g)
        if Duel.Destroy(g,REASON_EFFECT)~=0 then
            if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
                and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
                and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then                
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                local spg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
                if #spg>0 then
                    Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
                end
            end
        end
    end
end