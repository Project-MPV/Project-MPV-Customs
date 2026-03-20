--Illusion of Destiny
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)        
    --Redo and Choose
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_TOSS_COIN_NEGATE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.redocon)
    e2:SetOperation(s.redoop)
    c:RegisterEffect(e2)         
    --Toss
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_COIN+CATEGORY_RECOVER+CATEGORY_DRAW+CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.gtg)
    e3:SetOperation(s.gop)
    c:RegisterEffect(e3)
end
s.toss_coin=true
function s.redocon(e,tp,eg,ep,ev,re,r,rp)
    return re and re:GetHandler()~=e:GetHandler() and not Duel.HasFlagEffect(tp,id)
end
function s.redoop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.HasFlagEffect(tp,id) then return end
    if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
        Duel.Hint(HINT_CARD,0,id)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)       
        --Choose the result
        local opt=Duel.SelectOption(tp,60,61)
        local res=(opt==0) and 1 or 0
        local results={}
        for i=1,ev do
            table.insert(results,res)
        end
        Duel.SetCoinResult(table.unpack(results))
    end
end
function s.gtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.gop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end        
    local call=Duel.SelectOption(tp,60,61)
    local call_res=(call==0) and 1 or 0    
    local res=Duel.TossCoin(tp,1)      
    if res==call_res then
        Duel.Recover(tp,1000,REASON_EFFECT)
        Duel.Draw(tp,1,REASON_EFFECT)
    else
        if Duel.Destroy(c,REASON_EFFECT)>0 then
            Duel.Damage(tp,1000,REASON_EFFECT)
        end
    end
end