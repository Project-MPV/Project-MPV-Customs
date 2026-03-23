--Enlightenment Tempo
local s,id=GetID()
function s.initial_effect(c)
    aux.AddSkillProcedure(c,2,false,nil,nil)
    local e1=Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_STARTUP)
    e1:SetCountLimit(1)
    e1:SetRange(0x5f)
    e1:SetOperation(s.flipop)
    c:RegisterEffect(e1)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
    Duel.Hint(HINT_CARD,tp,id)
    local c=e:GetHandler()  
	--ATK/DEF Boost (Race Diversity)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x303))--Imaginary Force
    e1:SetValue(s.atkval)
    Duel.RegisterEffect(e1,tp)  
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    Duel.RegisterEffect(e2,tp)    
    if Duel.GetFlagEffect(tp,id)==0 then
        --Skill Activation
        local e3=Effect.CreateEffect(c)
        e3:SetDescription(aux.Stringid(id,0))
        e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e3:SetCode(EVENT_FREE_CHAIN)
        e3:SetCondition(s.skillcon)
        e3:SetOperation(s.skillop)
        Duel.RegisterEffect(e3,tp)
    end
end

function s.atkval(e,c)
    local tp=e:GetHandlerPlayer()
    local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)
    if #g==0 then return 0 end
    local race_count=g:GetClassCount(Card.GetRace)
    return race_count*200
end

function s.skillcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase() and Duel.GetTurnPlayer()==tp 
        and Duel.GetFlagEffect(tp,id)==0 
        and Duel.GetLP(tp)<=3000
end

function s.skillop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
    
    local opt1=Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_LIGHT)
    local opt2=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil)

    if not (opt1 or opt2) then return end   
    
    local op=Duel.SelectEffect(tp,
        {opt1,aux.Stringid(id,1)}, --Recover LIGHT
        {opt2,aux.Stringid(id,2)}) --Removal to Bottom Deck + SP
        
    if op==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_GRAVE,0,1,1,nil,0x303)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
        if #g>0 then
            Duel.HintSelection(g)
            if Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                local sp=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,0x303)
                if #sp>0 then
                    Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP)
                end
            end
        end
    end
    Duel.RegisterFlagEffect(tp,id,0,0,0)
end