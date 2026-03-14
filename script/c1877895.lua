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
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetCondition(function(e) return e:GetHandler():GetOverlayCount()>0 end)
    e1:SetValue(1)
    c:RegisterEffect(e1) 
    local e2=e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(e2)
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
	--Debuff Opponent: IF another monster is Rebirth Summoned
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.atkcon)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
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

function s.atkfilter(tc,e)
    return tc:IsFaceup() 
        and tc:IsSummonType(SUMMON_TYPE_REBIRTH) 
        and tc~=e:GetHandler() 
        and tc:IsHasEffect(EFFECT_REBIRTH_GRADE)
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.atkfilter,nil,e)
    if #g>0 then
        --If more than one appears simultaneously, take the highest Grade (Just for balance).
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=e:GetLabelObject()
    if not g then return end    
    --Count the highest GRADE
    local max_grade=0
    local tc_ally=g:GetFirst()
    while tc_ally do
        local eff=tc_ally:IsHasEffect(EFFECT_REBIRTH_GRADE)
        if eff and eff:GetValue()>max_grade then
            max_grade=eff:GetValue()
        end
        tc_ally=g:GetNext()
    end
    g:DeleteGroup() 
    if max_grade<=0 then return end
    local val=max_grade*200
    local opponent_g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    local dg=Group.CreateGroup()  
    for tc in aux.Next(opponent_g) do
        local old_atk=tc:GetAttack()
        local old_def=tc:GetDefense()        
        --Debuff ATK/DEF
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-val)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1) 
        local e2=e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        tc:RegisterEffect(e2)        
        --If become 0 (whichever is lower)
        local cur_atk=tc:GetAttack()
        local cur_def=tc:GetDefense()
        local lower_stat=math.min(cur_atk,cur_def)        
        if lower_stat==0 then
            dg:AddCard(tc)
        end
    end    
    --Destroy them
    if #dg>0 then
        Duel.BreakEffect()
        Duel.Destroy(dg,REASON_EFFECT)
    end
end