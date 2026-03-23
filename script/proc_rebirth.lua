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
REASON_REBIRTH       =0x40000000
EFFECT_REBIRTH_GRADE =0x30000000

--------------------------------------------------------------------------------
--FILTER UTILITY
--------------------------------------------------------------------------------
function Rebirth.TraceFilter(tc,c,filter,is_generic)
    local loc=(tc:IsLocation(LOCATION_GRAVE) or tc:IsLocation(LOCATION_REMOVED))
    if not (loc and tc:IsType(TYPE_MONSTER)) then return false end            
    if filter and type(filter)=="function" and not filter(tc,c) then return false end
    local has_grade=tc:IsHasEffect(EFFECT_REBIRTH_GRADE)    
    if is_generic then
        return has_grade 
    else
        return not has_grade
    end
end


function Rebirth.EvolutionCheck(grade, f_prime)
    return function(sg,e,tp,mg)
        if #sg==1 and f_prime(sg:GetFirst()) then return true end
        
        if sg:GetSum(Rebirth.GetMaterialValue)==grade then
            local ok=true
            for tc in aux.Next(sg) do
                if tc:IsHasEffect(EFFECT_REBIRTH_GRADE) then ok=false break end
            end
            return ok
        end
        return false
    end
end
--------------------------------------------------------------------------------
--STANDARD PROCEDURE
--------------------------------------------------------------------------------
function Rebirth.AddProcedure(c,grade,filter,min,max)
    local min= min or 1
    local max= max or 99
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(Rebirth.StandardCondition(grade,filter,min,max))
    e1:SetTarget(Rebirth.StandardTarget(grade,filter,min,max))
    e1:SetOperation(Rebirth.StandardOperation)
    e1:SetValue(SUMMON_TYPE_REBIRTH)
    c:RegisterEffect(e1)
    Rebirth.AddCommonEffects(c,grade)
end

function Rebirth.StandardCondition(grade,filter,min,max)
    return function(e,c,og)
        if c==nil then return true end
        local tp=c:GetControler()
        local zone=Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)
        if zone<=0 then return false end
        local mg=Duel.GetMatchingGroup(Rebirth.TraceFilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,c,filter,false)		
        return aux.SelectUnselectGroup(mg,e,tp,min,max,function(sg,e,tp,mg) 
            return sg:GetSum(Rebirth.GetMaterialValue)==grade 
        end,0)
    end
end

function Rebirth.StandardTarget(grade,filter,min,max)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,c)
        if chk==0 then return Rebirth.StandardCondition(grade,filter,min,max)(e,c,nil) end
        local mg=Duel.GetMatchingGroup(Rebirth.TraceFilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,c,filter,false)
        local cancelable=Duel.IsSummonCancelable()
        
        local sg=aux.SelectUnselectGroup(mg,e,tp,min,max,function(sg,e,tp,mg) 
            return sg:GetSum(Rebirth.GetMaterialValue)==grade end,1,tp,HINTMSG_MATERIAL,
            function(sg,e,tp,mg) return sg:GetSum(Rebirth.GetMaterialValue)==grade end,nil,cancelable)      
        
        if sg and #sg>0 and sg:GetSum(Rebirth.GetMaterialValue)==grade then
            sg:KeepAlive()
            e:SetLabelObject(sg)
            return true
        end
        return false 
    end
end


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
function Rebirth.AddEvolutionProcedure(c,grade,material_filter,filter)
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
    
    Rebirth.AddCommonEffects(c,grade)
end
--Helper to detect whether material_filter is an ID (number) or a Function
function Rebirth.GetEvoFilter(material_filter)
    if type(material_filter) == "number" then
        return function(tc) return tc:IsCode(material_filter) end
    else
        return material_filter
    end
end

function Rebirth.EvolutionCondition(grade,material_filter,filter)
    return function(e,c)
        if c==nil then return true end
        local tp=c:GetControler()
        if Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then return false end        
        local f_prime=Rebirth.GetEvoFilter(material_filter)        
        local mg_prime=Duel.GetMatchingGroup(f_prime,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
        local mg_std=Duel.GetMatchingGroup(Rebirth.TraceFilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,c,filter,false)       
        local mg=mg_std:Clone()
        mg:Merge(mg_prime)       
        return aux.SelectUnselectGroup(mg,e,tp,1,99,Rebirth.EvolutionCheck(grade,f_prime),0)
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
        local f_prime=Rebirth.GetEvoFilter(material_filter)
        if chk==0 then return Rebirth.EvolutionCondition(grade,material_filter,filter)(e,c) end
        
        local mg_prime=Duel.GetMatchingGroup(f_prime,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
        local mg_std=Duel.GetMatchingGroup(Rebirth.TraceFilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,c,filter,false)
        
        local mg=mg_std:Clone()
        mg:Merge(mg_prime)
        
        local cancelable=Duel.IsSummonCancelable()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
        local sg=aux.SelectUnselectGroup(mg,e,tp,1,99,Rebirth.EvolutionCheck(grade, f_prime),1,tp,HINTMSG_REMOVE,Rebirth.EvolutionCheck(grade, f_prime),nil,cancelable)
        
        if sg and #sg>0 then
            sg:KeepAlive()
            e:SetLabelObject(sg)
            if #sg==1 and f_prime(sg:GetFirst()) then
                e:SetLabel(1)--Prime
            else
                e:SetLabel(0)--Standard
            end
            return true
        end
        return false
    end
end

--------------------------------------------------------------------------------
--GENERIC
--------------------------------------------------------------------------------
--Specific filters for Generic & Combination
function Rebirth.GetOriginalValue(tc)
    if not tc then return 0 end
    local te=tc:IsHasEffect(EFFECT_REBIRTH_GRADE)
    if te then return te:GetValue() end
    return tc:GetOriginalLevel()
end
function Rebirth.TraceFilter_ValueSum(tc,c,filter)
    local loc=(tc:IsLocation(LOCATION_GRAVE) or tc:IsLocation(LOCATION_REMOVED))
    if not (loc and tc:IsType(TYPE_MONSTER)) then return false end            
    if filter and type(filter)=="function" and not filter(tc,c) then return false end
    return Rebirth.GetOriginalValue(tc)>0
end

function Rebirth.GetMaterialValue(tc)
    local eff=tc:IsHasEffect(EFFECT_REBIRTH_GRADE)
    if eff then
        local val=eff:GetValue()
        return (type(val)=="function" and val(eff,tc) or val) or 0
    end
    local lv=tc:GetLevel()
    if lv>0 then return lv end
    return -999999
end

function Rebirth.AddGenericProcedure(c,min,max,filter)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(Rebirth.GenericCondition(min,max,filter))
    e1:SetTarget(Rebirth.GenericTarget(min,max,filter))
    e1:SetOperation(Rebirth.Operation)
    e1:SetValue(SUMMON_TYPE_REBIRTH)
    c:RegisterEffect(e1)

    Rebirth.AddCommonEffects(c,grade or c:GetOriginalLevel())
end

function Rebirth.GenericCondition(min,max,filter)
    return function(e,c)
        if c==nil then return true end
        local tp=c:GetControler()
        local eff=c:IsHasEffect(EFFECT_REBIRTH_GRADE)
        local target_grade=eff and eff:GetValue() or c:GetOriginalLevel()       
        if Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then return false end       
        local mg=Duel.GetMatchingGroup(Rebirth.TraceFilter_ValueSum,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,c,filter,true)               
        return aux.SelectUnselectGroup(mg,e,tp,min,max,function(sg,e,tp,mg) 
            return sg:GetSum(function(tc)
                local te=tc:IsHasEffect(EFFECT_REBIRTH_GRADE)
                return te and te:GetValue() or tc:GetOriginalLevel()
            end)==target_grade 
        end,0)
    end
end

function Rebirth.GenericTarget(min,max,filter)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,c)
        if chk==0 then return Rebirth.GenericCondition(min,max,filter)(e,c) end        
        local eff=c:IsHasEffect(EFFECT_REBIRTH_GRADE)
        local target_grade=eff and eff:GetValue() or c:GetOriginalLevel()
        local cancelable=Duel.IsSummonCancelable()
        local mg=Duel.GetMatchingGroup(Rebirth.TraceFilter_ValueSum,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,c,filter)        
        local check_func=function(sg,e,tp,mg) 
            return sg:GetSum(function(tc)
                local te=tc:IsHasEffect(EFFECT_REBIRTH_GRADE)
                return te and te:GetValue() or tc:GetOriginalLevel()
            end)==target_grade 
        end
        local sg=aux.SelectUnselectGroup(mg,e,tp,min,max,check_func,1,tp,HINTMSG_REMOVED,check_func,nil,cancelable)        
        if sg and #sg>0 and check_func(sg,e,tp,mg) then
            sg:KeepAlive()
            e:SetLabelObject(sg)
            return true
        end
        return false
    end
end

--------------------------------------------------------------------------------
--COMBINATION
--------------------------------------------------------------------------------
function Rebirth.AddCombinationProcedure(c,min,max,filter,special_con)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(Rebirth.CombinationCondition(min,max,filter,special_con))
    e1:SetTarget(Rebirth.CombinationTarget(min,max,filter,special_con))
    e1:SetOperation(Rebirth.Operation)
    e1:SetValue(SUMMON_TYPE_REBIRTH)
    c:RegisterEffect(e1)
	
	Rebirth.AddCommonEffects(c,c:GetOriginalLevel())
end

function Rebirth.CombinationCondition(min,max,filter,special_con)
    return function(e,c)
        if c==nil then return true end
        local tp=c:GetControler()
        local eff=c:IsHasEffect(EFFECT_REBIRTH_GRADE)
        local target_grade=eff and eff:GetValue() or c:GetOriginalLevel()              
        if Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then return false end
        local mg=Duel.GetMatchingGroup(Rebirth.TraceFilter_ValueSum,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,c,filter)                       
        if special_con and not special_con(e,tp,mg) then return false end                     
        return aux.SelectUnselectGroup(mg,e,tp,min,max,function(sg,e,tp,mg) 
            return sg:GetSum(Rebirth.GetOriginalValue)==target_grade 
        end,0)
    end
end

function Rebirth.CombinationTarget(min,max,filter,special_con)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,c)
        if chk==0 then return Rebirth.CombinationCondition(min,max,filter,special_con)(e,c) end       
        local eff=c:IsHasEffect(EFFECT_REBIRTH_GRADE)
        local grade=eff and eff:GetValue() or c:GetOriginalLevel()
        local cancelable=Duel.IsSummonCancelable()
        local mg=Duel.GetMatchingGroup(Rebirth.TraceFilter_ValueSum,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,c,filter)        
        local check_func=function(sg,e,tp,mg) 
            return sg:GetSum(function(tc)
                local te=tc:IsHasEffect(EFFECT_REBIRTH_GRADE)
                return te and te:GetValue() or tc:GetOriginalLevel()
            end)==grade 
        end       
        local sg=aux.SelectUnselectGroup(mg,e,tp,min,max,check_func,1,tp,HINTMSG_REMOVED,check_func,nil,cancelable)       
        if sg and #sg>0 and check_func(sg,e,tp,mg) then
            sg:KeepAlive()
            e:SetLabelObject(sg)
            return true
        end
        return false
    end
end

function Rebirth.Operation(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if not g then return end
    c:SetMaterial(g)
    Duel.Overlay(c,g,REASON_REBIRTH+REASON_MATERIAL)
    c:RegisterFlagEffect(c:GetCode(),RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
    g:DeleteGroup()
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