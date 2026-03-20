--Alistair, Sovereign of the Blood Moon(Grade 10)
--scripted by fawwazzed
if not PROC_REBIRTH_LOADED then Duel.LoadScript("proc_rebirth.lua") end
if not MPV_CONSTANTS_IMPORTED then Duel.LoadScript("MPV_constant.lua") end
local s,id=GetID()
s.Rebirth=true
function s.initial_effect(c)
    c:EnableReviveLimit()
    --EVOLUTION: Alistair or Standard 10
    Rebirth.AddEvolutionProcedure(c,10,91877890) 
    --Blood Moon Gamble
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_COIN+CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
	e1:SetCondition(s.co)
    e1:SetTarget(s.cointg)
    e1:SetOperation(s.coinop)
    c:RegisterEffect(e1)
end
s.toss_coin=true
function s.atk(c)
	return (c:IsFaceup() and c:HasNonZeroAttack()) or c:IsSpellTrap()
end
function s.co(c,tp)
	return Duel.IsExistingMatchingCard(s.atk,tp,0,LOCATION_ONFIELD,1,nil)
end
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.atk,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end

function s.coinfate(c)
    return true 
end

function s.coinop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local heads=0
    -- Throw until TAILS
    while Duel.TossCoin(tp,1)==COIN_HEADS do
        heads=heads+1
        local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
        if #g>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local sg=g:Select(tp,1,1,nil)
            if #sg>0 then
                Duel.HintSelection(sg)
                local tc=sg:GetFirst()                               
                --If face-up Monster:Debuff. If not (Facedown/ST), destroy.
                if tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
                    local e1=Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_UPDATE_ATTACK)
                    e1:SetValue(-1500)
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                    tc:RegisterEffect(e1)                
                    if tc:IsAttack(0) then
                        if Duel.Destroy(tc,REASON_EFFECT)>0 then
                            Duel.Damage(1-tp,1000,REASON_EFFECT)
                        end
                    end
                else
                    if Duel.Destroy(tc,REASON_EFFECT)>0 then
                        Duel.Damage(1-tp,1000,REASON_EFFECT)
                    end
                end
            end
        end
        Duel.BreakEffect()
    end 
    --If TAILS (only 1st try)
    if heads==0 and c:IsRelateToEffect(e) and c:IsFaceup() then
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_UPDATE_ATTACK)
        e2:SetValue(-1500)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e2)       
        --Self-Destruct if ATK reach 0
        if c:GetAttack()==0 then
            Duel.Destroy(c,REASON_EFFECT)
        end
    end
end