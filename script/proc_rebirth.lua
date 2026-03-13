--Rebirth Summon Utility
--Based on Dimitri's Rulings Document
--Implemented and Simplified for Edopro by fawwazzed

if not Rebirth then
    Rebirth = {}
end
if not SUMMON_TYPE_REBIRTH then 
    SUMMON_TYPE_REBIRTH = SUMMON_TYPE_SPECIAL|0x189
end
if not REASON_REBIRTH then
    REASON_REBIRTH = 0x400000000
end
if not aux.RebirthProcedure then
    aux.RebirthProcedure = Rebirth
end

SUMMON_TYPE_REBIRTH  =SUMMON_TYPE_SPECIAL|0x189
EFFECT_REBIRTH_GRADE =0x30000000

--------------------------------------------------------------------------------
--FILTER UTILITY
--------------------------------------------------------------------------------

function Rebirth.TraceFilter(tc, filter)
    return (tc:IsLocation(LOCATION_GRAVE) or tc:IsLocation(LOCATION_REMOVED)) 
        and tc:GetLevel()>0
        and (not filter or filter(tc))
end

function Rebirth.TraceFilterCombination(tc, materials)
    return (tc:IsLocation(LOCATION_GRAVE) or tc:IsLocation(LOCATION_REMOVED))
        and (tc:IsHasEffect(EFFECT_REBIRTH_GRADE) or tc:IsCode(table.unpack(materials)))
end

--------------------------------------------------------------------------------
--STANDARD PROCEDURE
--------------------------------------------------------------------------------
function Rebirth.AddProcedure(c, grade, filter)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(Rebirth.StandardCondition(grade, filter))
    e1:SetTarget(Rebirth.StandardTarget(grade, filter))
    e1:SetOperation(Rebirth.StandardOperation)
    e1:SetValue(SUMMON_TYPE_REBIRTH)
    c:RegisterEffect(e1)
    Rebirth.AddCommonEffects(c, grade)
end

function Rebirth.StandardCondition(grade, filter)
    return function(e,c,og)
        if c==nil then return true end
        local tp=c:GetControler()
        local zone=Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)
        if zone<=0 then return false end
        local mg=Duel.GetMatchingGroup(Rebirth.TraceFilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,filter)        
        return aux.SelectUnselectGroup(mg,e,tp,1,#mg,function(sg,e,tp,mg) 
            return sg:GetSum(Card.GetLevel)==grade 
        end,0)
    end
end

function Rebirth.StandardTarget(grade, filter)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,c)
        if chk==0 then return Rebirth.StandardCondition(grade,filter)(e,c,nil) end
        local mg=Duel.GetMatchingGroup(Rebirth.TraceFilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,filter)
        local cancelable=Duel.IsSummonCancelable()
        
        local sg=aux.SelectUnselectGroup(mg,e,tp,1,99,function(sg,e,tp,mg) 
            return sg:GetSum(Card.GetLevel)==grade end,1,tp,HINTMSG_REMOVED,nil,nil,cancelable)      
        --Check if sg is present AND the total level is correct according to grade
        if sg and #sg>0 and sg:GetSum(Card.GetLevel)==grade then
            sg:KeepAlive()
            e:SetLabelObject(sg)
            return true
        else
            return false 
        end
    end
end

REASON_REBIRTH= 0x40000000

function Rebirth.StandardOperation(e,tp,eg,ep,ev,re,r,rp,c)
    local sg=e:GetLabelObject()
    if not sg then return end
    c:SetMaterial(sg)
    Duel.Overlay(c,sg,REASON_MATERIAL+REASON_REBIRTH)
    local res = e:GetLabel() or 0
    c:RegisterFlagEffect(c:GetCode(),RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1,res)
    sg:DeleteGroup()
end

--------------------------------------------------------------------------------
-- EVOLUTION (PRIME REBIRTH)
--------------------------------------------------------------------------------
-- c: summoned card
-- grade: total level for standard
-- material_filter: Prime Specific(it can be ID or function)
function Rebirth.AddEvolutionProcedure(c, grade, material_filter, filter)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(Rebirth.EvolutionCondition(grade, material_filter, filter))
    e1:SetTarget(Rebirth.EvolutionTarget(grade, material_filter, filter))
    e1:SetOperation(Rebirth.StandardOperation)
    e1:SetValue(SUMMON_TYPE_REBIRTH)
    c:RegisterEffect(e1)
    
    Rebirth.AddCommonEffects(c, grade)
end
--Helper to detect whether material_filter is an ID (number) or a Function
function Rebirth.GetEvoFilter(material_filter)
    if type(material_filter) == "number" then
        return function(tc) return tc:IsCode(material_filter) end
    else
        return material_filter
    end
end
function Rebirth.EvolutionCondition(grade, material_filter, filter)
    return function(e,c,og)
        if c==nil then return true end
        local tp=c:GetControler()
        local zone=Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)
        if zone<=0 then return false end
        
        local f=Rebirth.GetEvoFilter(material_filter)        
        local b1=Duel.IsExistingMatchingCard(f,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
        --Standard (Total Level)
        local b2=Rebirth.StandardCondition(grade,filter)(e,c,og)        
        return b1 or b2
    end
end

function Rebirth.EvolutionFilter(tc, base_id) 
    --ID.
    return (tc:IsLocation(LOCATION_GRAVE) or tc:IsLocation(LOCATION_REMOVED)) 
        and tc:IsCode(base_id)
end

function Rebirth.GetEvoFilter(material_filter)
    if type(material_filter) == "number" then
        return function(tc) return tc:IsCode(material_filter) end
    else
        return material_filter
    end
end

function Rebirth.EvolutionTarget(grade, material_filter, filter)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,c)
        if chk==0 then return Rebirth.EvolutionCondition(grade,material_filter,filter)(e,c,nil) end
        
        local f=Rebirth.GetEvoFilter(material_filter)
        local mg_evo=Duel.GetMatchingGroup(f,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
        local mg_std=Duel.GetMatchingGroup(Rebirth.TraceFilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,filter)
        
        local b1= #mg_evo>0
        local b2= Rebirth.StandardCondition(grade,filter)(e,c,nil)
        
        local cancelable= Duel.IsSummonCancelable()
        local options= {}
        local auth= {}
        
        --Prime Line:stringid(7)
        if b1 then 
            local sample = mg_evo:GetFirst()
            table.insert(options, aux.Stringid(sample:GetCode(),7)) 
            table.insert(auth, 1) 
        end 
        --Standard
        if b2 then 
            table.insert(options,aux.Stringid(c:GetCode(),8)) 
            table.insert(auth,0) 
        end 

        if #options==0 then return false end
        
        local op=0
        if #options>1 then
            op=Duel.SelectOption(tp, table.unpack(options))
        end
        
        local choice= auth[op+1]
        local sg=nil
        
        if choice==1 then --PRIME
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            sg=mg_evo:Select(tp,1,1,nil)
            
            if sg and #sg ==1 then
                sg:KeepAlive()
                e:SetLabelObject(sg)
                e:SetLabel(1)--Bonus Prime
                return true
            end
        else --STANDARD
            sg=aux.SelectUnselectGroup(mg_std,e,tp,1,99,function(sg,e,tp,mg) 
                return sg:GetSum(Card.GetLevel)==grade end,1,tp,HINTMSG_REMOVE,nil,nil,cancelable)

            if sg and #sg>0 and sg:GetSum(Card.GetLevel)==grade then
                sg:KeepAlive()
                e:SetLabelObject(sg)
                e:SetLabel(0)
                return true
            end
        end
        
        return false
    end
end

--------------------------------------------------------------------------------
--GENERIC
--------------------------------------------------------------------------------
function Rebirth.AddGenericProcedure(c, target_grade, filter)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(Rebirth.GenericCondition(target_grade, filter))
    e1:SetTarget(Rebirth.GenericTarget(target_grade, filter))
    e1:SetOperation(Rebirth.StandardOperation)
    e1:SetValue(SUMMON_TYPE_REBIRTH)
    c:RegisterEffect(e1)
    Rebirth.AddCommonEffects(c, target_grade)
end

function Rebirth.GenericCondition(target_grade, filter)
    return function(e,c,og)
        if c==nil then return true end
        local tp=c:GetControler()
        local mg=Duel.GetMatchingGroup(Rebirth.TraceFilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,filter)        
        return mg:IsExists(Card.IsHasEffect,1,nil,EFFECT_REBIRTH_GRADE) 
            and aux.SelectUnselectGroup(mg,e,tp,2,99,function(sg,e,tp,mg) 
                return sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_REBIRTH_GRADE)
                and sg:GetSum(function(sc)
                    local lv=sc:GetLevel()
                    if lv>0 then return lv end
                    local ge=sc:GetCardEffect(EFFECT_REBIRTH_GRADE)
                    return ge and ge:GetValue() or 0
                end)==target_grade 
            end,0)
    end
end

function Rebirth.GenericTarget(target_grade, filter)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,c)
        if chk==0 then return Rebirth.GenericCondition(target_grade,filter)(e,c,nil) end
        local cancelable=Duel.IsSummonCancelable()
        local mg=Duel.GetMatchingGroup(Rebirth.TraceFilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,filter)
        
        local sg=aux.SelectUnselectGroup(mg,e,tp,2,99,function(sg,e,tp,mg) 
            return sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_REBIRTH_GRADE)
            and sg:GetSum(function(sc)
                local lv=sc:GetLevel()
                if lv>0 then return lv end
                local ge=sc:GetCardEffect(EFFECT_REBIRTH_GRADE)
                return ge and ge:GetValue() or 0
            end)==target_grade 
        end,1,tp,HINTMSG_REMOVED,nil,nil,cancelable)
        
        if sg and #sg>0 then
            sg:KeepAlive()
            e:SetLabelObject(sg)
            e:SetLabel(0)
            return true
        end
        return false
    end
end

--------------------------------------------------------------------------------
--COMBINATION
--------------------------------------------------------------------------------
function Rebirth.AddCombinationProcedure(c, ...)
    local materials = {...}
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(Rebirth.CombinationCondition(materials))
    e1:SetTarget(Rebirth.CombinationTarget(materials))
    e1:SetOperation(Rebirth.StandardOperation)
    e1:SetValue(SUMMON_TYPE_REBIRTH)
    c:RegisterEffect(e1)
    Rebirth.AddCommonEffects(c)
end

function Rebirth.CombinationCondition(materials)
    return function(e,c,og)
        if c==nil then return true end
        local tp=c:GetControler()
        local mg=Duel.GetMatchingGroup(Rebirth.TraceFilterCombination,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,materials)      
        for _,code in ipairs(materials) do
            if not mg:IsExists(Card.IsCode,1,nil,code) then return false end
        end
        return true
    end
end

function Rebirth.CombinationTarget(materials)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,c)
        if chk==0 then return Rebirth.CombinationCondition(materials)(e,c,nil) end
        local mg=Duel.GetMatchingGroup(Rebirth.TraceFilterCombination,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,materials)
        local cancelable=Duel.IsSummonCancelable()
        local sg=Group.CreateGroup()
        
        for _,code in ipairs(materials) do
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVED)
            local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,cancelable,nil,code)
            if g and #g>0 then 
                sg:Merge(g) 
            else 
                return false
            end
        end
        
        sg:KeepAlive()
        e:SetLabelObject(sg)
        e:SetLabel(0)
        return true
    end
end

--------------------------------------------------------------------------------
--COMMON EFFECTS
--------------------------------------------------------------------------------
function Rebirth.AddCommonEffects(c, grade)
    c:SetStatus(STATUS_NO_LEVEL,true)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
    e0:SetRange(LOCATION_ALL)
    e0:SetCode(EFFECT_REMOVE_TYPE)
    e0:SetValue(TYPE_FUSION)
    c:RegisterEffect(e0)   
    local e1=Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_REBIRTH_GRADE)
    e1:SetValue(grade or 0)
    c:RegisterEffect(e1) 
    local e2=Effect.CreateEffect(c)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)   
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_USE_AS_COST)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(1,1)
    e2:SetTarget(function(e,tc,tp,re)
        return tc:GetOverlayTarget()==e:GetHandler() and re:IsHasType(0x7e)
    end)
    c:RegisterEffect(e2)
end

PROC_REBIRTH_LOADED = true