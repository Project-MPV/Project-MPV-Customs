local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(id,0)
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_DESTROYED or EVENT_LEAVE_FIELD or EVENT_DISCARD)
    e1:SetCondition(s.drawsetup)
    e1:SetOperation(s.draw)
end

function s.drawsetup(e,tp,eg,ep,ev,re,r,rp,chk)
    if ckh==0 then return Duel.IsPlayerCanDraw(tp,2) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(2)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end

function s.draw(e,tp,eg,ep,ev,re,r,rp)
    local Duel.Draw(p,d,REASON_EFFECT)
end