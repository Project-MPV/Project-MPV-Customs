--Blazing Phoenix Overlord (Grade 13)
--scripted by fawwazzed
if not PROC_REBIRTH_LOADED then Duel.LoadScript("proc_rebirth.lua") end
if not MPV_CONSTANTS_IMPORTED then Duel.LoadScript("MPV_constant.lua") end
local s,id=GetID()
s.Rebirth=true
function s.initial_effect(c)
    c:EnableReviveLimit()   
    --GENERIC PROCEDURE
    Rebirth.AddGenericProcedure(c,3,3,s.matfilter)  
    --Cannot be destroyed as long as there is material
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE)
    e1:SetCondition(function(e) return e:GetHandler():GetOverlayCount()>0 end)
    e1:SetValue(1)
    c:RegisterEffect(e1)
	--Temporary Rebirth (SS from Soul)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.sscon)
    e2:SetTarget(s.sstg)
    e2:SetOperation(s.ssop)
    c:RegisterEffect(e2)
end
--FIRE Rebirth Monster 
function s.matfilter(tc)
    return tc:IsAttribute(ATTRIBUTE_FIRE) and tc:IsHasEffect(EFFECT_REBIRTH_GRADE)
end
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_REBIRTH)
end

function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then 
        local g=c:GetOverlayGroup()
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
            and g:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false) 
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.ssop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:GetOverlayCount()==0 then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end   
    local g=c:GetOverlayGroup()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=g:FilterSelect(tp,Card.IsCanBeSpecialSummoned,1,1,nil,e,0,tp,false,false)   
    local tc=sg:GetFirst()    
    if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_REBIRTH,tp,tp,false,false,POS_FACEUP)>0 then
        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)              
        --Return to Soul (End Phase)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e1:SetLabelObject(tc)
        e1:SetCondition(s.retcon)
        e1:SetOperation(s.retop)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    return tc:GetFlagEffect(id)~=0
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    local c=e:GetOwner()
    if c:IsLocation(LOCATION_MZONE) and tc:IsLocation(LOCATION_MZONE) then
        Duel.Overlay(c,tc)
    end
end