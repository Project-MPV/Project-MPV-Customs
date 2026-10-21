--Anarisa The Exfrost Princess
--scripted by fawwazzed
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),1,1,Synchro.NonTuner(nil),1,99)  
    --Debuff
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_DEFCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetTarget(s.atktg)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)  
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_CHAINING)
    e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
	e1:SetCountLimit(1,id)
	e2:SetCountLimit(1,id)
    --Double Battle Damage against 0 ATK or DEF monsters
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e3:SetTarget(s.damtg)
    e3:SetValue(DOUBLE_DAMAGE)
    c:RegisterEffect(e3)
	--Prevent first damage taken each turn
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CHANGE_DAMAGE)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(1,0)
    e4:SetValue(s.damval)
    c:RegisterEffect(e4)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsActiveType(TYPE_MONSTER) and re:GetHandler()~=e:GetHandler()
end
function s.wfilter(c)
    return c:IsAttribute(ATTRIBUTE_WATER)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
        and Duel.IsExistingMatchingCard(s.wfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    local ct=Duel.GetMatchingGroupCount(s.wfilter,tp,LOCATION_GRAVE,0,nil)
    if #g>0 and ct>0 then
        local val=ct*600
        for tc in aux.Next(g) do
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(-val)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            tc:RegisterEffect(e1)           
            local e2=e1:Clone()
            e2:SetCode(EFFECT_UPDATE_DEFENSE)
            tc:RegisterEffect(e2)
        end
    end
end
function s.damtg(e,c)
    return c:IsAttack(0) or c:IsDefense(0)
end
function s.damval(e,re,val,r,rp,rc)
    if Duel.GetFlagEffect(e:GetHandlerPlayer(),id)==0 then
        Duel.RegisterFlagEffect(e:GetHandlerPlayer(),id,RESET_PHASE|PHASE_END,0,1)
        return 0
    end
    return val
end