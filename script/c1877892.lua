--Blue Phoenix Knight (Grade 10)
--ID 1877892
--scripted by fawwazzed
if not PROC_REBIRTH_LOADED then Duel.LoadScript("proc_rebirth.lua") end
if not MPV_CONSTANTS_IMPORTED then Duel.LoadScript("MPV_constant.lua") end
local s,id=GetID()
s.Rebirth=true
function s.initial_effect(c)
    c:EnableReviveLimit()    
    --Prime Rebirth: EVOLUTION
    --You can perform EVOLUTION using 1 Phoenix Knight in GY OR just use total Level 10 for Normal Rebirth
    Rebirth.AddEvolutionProcedure(c,10,1877891,nil)  
    --Burn on Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.burncon)
    e1:SetTarget(s.burntg)
    e1:SetOperation(s.burnop)
    c:RegisterEffect(e1) 
    --Soul Armor (Protection)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetCondition(s.protcon)
    e2:SetValue(1)
    c:RegisterEffect(e2)  
    --Rebirth Cycle (Self-Resurrection)
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1,id)
    e4:SetCondition(s.revivecon)
    e4:SetTarget(s.revivetg)
    e4:SetOperation(s.reviveop)
    c:RegisterEffect(e4)
end
--Burn
function s.burncon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_REBIRTH)
end
function s.burntg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local ct=e:GetHandler():GetOverlayCount()
    Duel.SetTargetPlayer(1-tp)
end
function s.burnop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
    local ct=c:GetOverlayCount()
    local bonus=c:GetFlagEffectLabel(id)
    
    local damage=ct*500
    if bonus==1 then
        damage=damage+1200 --Prime Rebirth Summoned only
    end
    
    if ct>0 then
        Duel.Damage(p,damage,REASON_EFFECT)
    end
end

function s.protcon(e)
    return e:GetHandler():GetOverlayCount()>0
end

function s.revivecon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_REBIRTH)
        and c:IsReason(REASON_DESTROY)
        and c:GetTurnID()==Duel.GetTurnCount() 
end
function s.revivetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
end
function s.reviveop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
				if #g>0 then
				Duel.HintSelection(g)
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
    end
end