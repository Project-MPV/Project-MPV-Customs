--Samsara HERO Infernal Gustman
--Grade 6
if not PROC_REBIRTH_LOADED then Duel.LoadScript("proc_rebirth.lua") end
if not MPV_CONSTANTS_IMPORTED then Duel.LoadScript("MPV_constant.lua") end
local s,id=GetID()
s.Rebirth=true
function s.initial_effect(c)
    c:EnableReviveLimit()
    --REBIRTH SUMMON: 2 "HERO" Monsters
    Rebirth.AddProcedure(c,6,s.matfilter,2,2)     
    --Gains 200 ATK for each "HERO" in Soul Zone
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)   
    --Burn & Heal when destroying monster by battle (seriously tho, why you still use "When" effect....)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetCondition(aux.bdgcon)
    e2:SetCost(s.damcost)
    e2:SetTarget(s.damtg)
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)
end
s.listed_series={0x8}
function s.matfilter(c)
    return c:IsSetCard(0x8) --if you also want to filter level just add this e.g: and c:GetLevel()==4
end
--This just so it can't check Material other than "Soul Material"
function s.atkval(e,c)
    local tp=e:GetHandlerPlayer()
    local g=Duel.GetMatchingGroup(function(target) return target:IsFaceup() and target:IsHasEffect(EFFECT_REBIRTH_GRADE) end,tp,LOCATION_MZONE,0,nil)   
    local total_hero_soul=0
    local tc=g:GetFirst()   
    while tc do
        local mg=tc:GetOverlayGroup()
        if #mg>0 then
            total_hero_soul=total_hero_soul+mg:FilterCount(Card.IsSetCard,nil,0x8)
        end
        tc=g:GetNext()
    end   
    return total_hero_soul*200
end

function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end 
    local sg=c:GetOverlayGroup():Select(tp,1,1,nil)   
    --RECOVER Label
    e:SetLabel(sg:GetFirst():GetBaseAttack())
    Duel.SendtoGrave(sg,REASON_COST)
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local tc=e:GetHandler():GetBattleTarget()
    if chk==0 then return tc:IsLocation(LOCATION_GRAVE) and tc:IsMonster() end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tc:GetAttack())
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel())
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetHandler():GetBattleTarget()
    local rec=e:GetLabel() --Retrieving ATK value from s.cost, pardon the g.translate   
    if tc:IsLocation(LOCATION_GRAVE) then
        local dam=tc:GetAttack()
        if Duel.Damage(1-tp,dam,REASON_EFFECT)>0 then
            Duel.Recover(tp,rec,REASON_EFFECT)
        end
    end
end