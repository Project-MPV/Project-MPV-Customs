--Burst Phoenix Knight (Grade 8)
--scripted by fawwazzed
if not PROC_REBIRTH_LOADED then Duel.LoadScript("proc_rebirth.lua") end
local s,id=GetID()
s.Rebirth=true
function s.initial_effect(c)
    c:EnableReviveLimit()   
    --REBIRTH SUMMON: 2 Level 4 Monsters= Grade 8
    Rebirth.AddProcedure(c,8,nil,2,2) 
    --To Extra Deck & Destroy S/T
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tgtarget)
    e1:SetOperation(s.tgoperation)
    c:RegisterEffect(e1)
end
function s.gyfilter(tc)
    return tc:IsHasEffect(EFFECT_REBIRTH_GRADE) and tc:IsAbleToExtra()
end

function s.tgtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.gyfilter(chkc) end
    if chk==0 then 
        return e:GetHandler():GetOverlayCount()>0 
        and Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil) 
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
end

function s.tgoperation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()    
    --Send all Soul Materials to GY
    if c:IsRelateToEffect(e) and c:GetOverlayCount()>0 then
        local mg=c:GetOverlayGroup()
        if Duel.SendtoGrave(mg,REASON_EFFECT)>0 then
            --Return target to Extra Deck
            if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)>0 then
                --Check Grade for bonus destruction
                local grade_eff=tc:IsHasEffect(EFFECT_REBIRTH_GRADE)
                if grade_eff and grade_eff:GetValue()>=5 then
                    local sg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
                    if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
                        Duel.BreakEffect()
                        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
                        local dg=sg:Select(tp,1,1,nil)
                        Duel.HintSelection(dg)
                        Duel.Destroy(dg,REASON_EFFECT)
                    end
                end
            end
        end
    end
end