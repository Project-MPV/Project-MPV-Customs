local s,id=GetID()
function s.initial_effect(c)
    Xyz.AddProcedure(c,nil,4,3,s.ovfilter,aux.Stringid(id,0))
    c:EnableReviveLimit()
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_ATKCHANGE)
    e1:
end

function s.ovfilter(c,tp,lc)
    return c:IsFaceup() and c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,9000)
end