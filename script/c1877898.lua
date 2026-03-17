--Phoenix Combination - Armored Knight
--Grade 12
local s,id=GetID()
if not PROC_REBIRTH_LOADED then Duel.LoadScript("proc_rebirth.lua") end
function s.initial_effect(c)
    c:EnableReviveLimit()
    --COMBINATION PROCEDURE: 1 Grade 8 + 1+ Level 4 or lower (Total 12)
    Rebirth.AddCombinationProcedure(c,2,99,s.matfilter,s.prime_con)    
    --Inflict damage on Rebirth Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.damcon)
    e1:SetTarget(s.damtg)
    e1:SetOperation(s.damop)
    c:RegisterEffect(e1)    
    --Return Soul to Deck for ATK Buff
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
end
function s.matfilter(tc,c)
    if tc:IsHasEffect(EFFECT_REBIRTH_GRADE) then
        return tc:IsHasEffect(EFFECT_REBIRTH_GRADE):GetValue()==8
    else
        return tc:GetLevel()<=4
    end
end
--Must have "Phoenix Knight" in GY
function s.prime_con(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,1877891)
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_REBIRTH)
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetOverlayCount()>0 end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=c:GetOverlayGroup():Filter(function(tc) 
        return tc:GetAttack()<=3000 or tc:GetDefense()<=3000 
    end,nil)
    
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
        local sc=g:Select(tp,1,1,nil):GetFirst()
        local dam=math.max(sc:GetAttack(),sc:GetDefense())
        if dam>3000 then dam=3000 end
        Duel.Damage(1-tp,dam,REASON_EFFECT)
    end
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetOverlayCount()>0 end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_OVERLAY)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:GetOverlayCount()==0 then return end  
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sc=c:GetOverlayGroup():Select(tp,1,1,nil):GetFirst()  
    if sc then
        local atk=math.max(sc:GetAttack(),sc:GetDefense())
        if Duel.SendtoDeck(sc,nil,SEQ_DECKTOP,REASON_EFFECT)>0 then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
            c:RegisterEffect(e1)
        end
    end
end