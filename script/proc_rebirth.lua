--Rebirth Summon Utility
--Based on Dimitri's Rulings Document
--Implemented and Simplified for Edopro by fawwazzed

if not Rebirth then
    Rebirth = {}
end
if not SUMMON_TYPE_REBIRTH then 
    SUMMON_TYPE_REBIRTH =SUMMON_TYPE_SPECIAL|0x189
end
if not aux.RebirthProcedure then
    aux.RebirthProcedure =Rebirth
end
SUMMON_TYPE_REBIRTH  =SUMMON_TYPE_SPECIAL|0x189
REASON_REBIRTH       =0x40000000
EFFECT_REBIRTH_GRADE =0x30000000
REBIRTH_FLAG_ON_FIELD=0x1890001
--------------------------------------------------------------------------------
--Monsters must be summoned to the field first (Experimental)
--------------------------------------------------------------------------------
function Rebirth.InitGlobalTracker()
    if Rebirth.TrackerInitialized then return end
    Rebirth.TrackerInitialized=true
    local ge1=Effect.GlobalEffect()
    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge1:SetCode(EVENT_LEAVE_FIELD)
    ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        for tc in aux.Next(eg) do
            tc:RegisterFlagEffect(REBIRTH_FLAG_ON_FIELD,RESET_EVENT+RESETS_STANDARD-RESET_TOGRAVE-RESET_REMOVE-RESET_LEAVE,0,1)
        end
    end)
    Duel.RegisterEffect(ge1,0)
end
function Rebirth.IsProperlySummoned(tc)
    if tc:IsHasEffect(EFFECT_REVIVE_LIMIT) or tc:IsType(TYPE_RITUAL|TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK|TYPE_EXTRA) then
        return tc:IsStatus(STATUS_PROC_COMPLETE)
    end
    return tc:GetFlagEffect(REBIRTH_FLAG_ON_FIELD)>0
end
function Rebirth.FastCanSum(mg,target,min_mat,max_mat,val_func)
    if not target or target<=0 then return false end
    local vals={}
    for tc in aux.Next(mg) do
        local v=val_func(tc)
        if v>0 and v<=target then
            table.insert(vals,v)
        end
    end
    if #vals<min_mat then return false end
    local eff_max=math.min(max_mat or 99,target)
    local dp={[0]=1}
    for _,v in ipairs(vals) do
        for s=target-v,0,-1 do
            if dp[s] then
                dp[s+v]=(dp[s+v] or 0)|(dp[s]<<1)
            end
        end
    end
    local valid=dp[target]
    if not valid then return false end
    for count=min_mat,eff_max do
        if (valid&(1<<count))~=0 then return true end
    end
    return false
end
--COMBINATION (Grade+Level check)
function Rebirth.FastCanSumCombo(mg,target,min_mat,max_mat,init_state)
    init_state = init_state or 0
    if target==0 then
        return min_mat<=0 and init_state==3
    end
    if not target or target<0 then return false end
    local items={}
    for tc in aux.Next(mg) do
        local v=Rebirth.GetMixValue(tc)
        if v>0 and v<=target then
            table.insert(items,{val=v,is_grade=tc:IsHasEffect(EFFECT_REBIRTH_GRADE)~=nil})
        end
    end
    if #items<min_mat then return false end
    local eff_max=math.min(max_mat or 99,target)
    local dp={[0]={[init_state]=1}}
    for _,item in ipairs(items) do
        local v=item.val
        local bit=item.is_grade and 2 or 1
        for s=target-v,0,-1 do
            if dp[s] then
                for st,mask in pairs(dp[s]) do
                    local nst=st|bit
                    dp[s+v]=dp[s+v] or {}
                    dp[s+v][nst]=(dp[s+v][nst] or 0)|(mask<<1)
                end
            end
        end
    end
    local valid=dp[target] and dp[target][3]
    if not valid then return false end
    for count=min_mat,eff_max do
        if (valid&(1<<count))~=0 then return true end
    end
    return false
end
--------------------------------------------------------------------------------
--FILTER UTILITY
--------------------------------------------------------------------------------
function Rebirth.TraceFilter(tc,c,filter,is_generic)
    local loc=(tc:IsLocation(LOCATION_GRAVE) or tc:IsLocation(LOCATION_REMOVED))
    if not (loc and tc:IsType(TYPE_MONSTER)) then return false end
	if not Rebirth.IsProperlySummoned(tc) then return false end	
    if filter and type(filter)=="function" and not filter(tc,c) then return false end
    local has_grade=tc:IsHasEffect(EFFECT_REBIRTH_GRADE)    
    if is_generic then
        return has_grade 
    else
        return not has_grade
    end
end
function Rebirth.SelectMaterials(mg,tp,target,min_mat,max_mat,val_func,cancelable,hint)
    local sg=Group.CreateGroup()
    local eff_max=math.min(max_mat or 99,target)
    while #sg<eff_max do
        local cur_sum=sg:GetSum(val_func)
        local rem=target-cur_sum
        local finish=(cur_sum==target and #sg>=min_mat)
        local cancel=(cancelable and #sg==0)
        local cg=Group.CreateGroup()
        if rem>0 then
            local rem_g=mg:Clone()
            rem_g:Sub(sg)
            local min_need=math.max(0,min_mat-#sg-1)
            local max_need=eff_max-#sg-1
            for tc in aux.Next(rem_g) do
                local v=val_func(tc)
                if v>0 and v<=rem then
                    if v==rem and (#sg+1)>=min_mat then
                        cg:AddCard(tc)
                    elseif max_need>0 then
                        local test_g=rem_g:Clone()
                        test_g:RemoveCard(tc)
                        if Rebirth.FastCanSum(test_g,rem-v,min_need,max_need,val_func) then
                            cg:AddCard(tc)
                        end
                    end
                end
            end
        end
        if #cg==0 and not finish then break end
        Duel.Hint(HINT_SELECTMSG,tp,hint or HINTMSG_CONFIRM)
        local tc=Group.SelectUnselect(cg,sg,tp,finish,cancel,min_mat,eff_max)
        if not tc then break end
        if not sg:IsContains(tc) then
            sg:AddCard(tc)
        else
            sg:RemoveCard(tc)
        end
    end
    if #sg>=min_mat and sg:GetSum(val_func)==target then return sg end
    return nil
end
function Rebirth.EvolutionCheck(grade,f_prime)
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
        if Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then return false end
        local mg=Duel.GetMatchingGroup(Rebirth.TraceFilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,c,filter,false)
        return Rebirth.FastCanSum(mg,grade,min,max,Rebirth.GetMaterialValue)
    end
end
function Rebirth.StandardTarget(grade,filter,min,max)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,c)
        if chk==0 then return Rebirth.StandardCondition(grade,filter,min,max)(e,c,nil) end
        local mg=Duel.GetMatchingGroup(Rebirth.TraceFilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,c,filter,false)
		local cancelable=Duel.IsSummonCancelable()
        local sg=Rebirth.SelectMaterials(mg,tp,grade,min,max,Rebirth.GetMaterialValue,cancelable,HINTMSG_CONFIRM)
        if sg then
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
    local res=e:GetLabel() or 0
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
    e1:SetCondition(Rebirth.EvolutionCondition(grade,material_filter,filter))
    e1:SetTarget(Rebirth.EvolutionTarget(grade,material_filter,filter))
    e1:SetOperation(Rebirth.StandardOperation)
    e1:SetValue(SUMMON_TYPE_REBIRTH)
    c:RegisterEffect(e1)
    
    Rebirth.AddCommonEffects(c,grade)
end
--Helper to detect whether material_filter is an ID (number) or a Function
function Rebirth.GetEvoFilter(material_filter)
    local base_f
    if type(material_filter)=="number" then
        base_f=function(tc) return tc:IsCode(material_filter) end
    else
        base_f=material_filter
    end
    return function(tc)
        return (tc:IsLocation(LOCATION_GRAVE) or tc:IsLocation(LOCATION_REMOVED))
            and Rebirth.IsProperlySummoned(tc) and base_f(tc)
    end
end
function Rebirth.EvolutionCondition(grade,material_filter,filter)
	return function(e,c)
		if c==nil then return true end
		local tp=c:GetControler()
		if Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then return false end
		local f_prime=Rebirth.GetEvoFilter(material_filter)
		if Duel.IsExistingMatchingCard(f_prime,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) then return true end
		local mg_std=Duel.GetMatchingGroup(Rebirth.TraceFilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,c,filter,false)
		return Rebirth.FastCanSum(mg_std,grade,1,grade,Rebirth.GetMaterialValue)
	end
end
function Rebirth.EvolutionFilter(tc,base_id) 
    --ID Check
    return (tc:IsLocation(LOCATION_GRAVE) or tc:IsLocation(LOCATION_REMOVED)) 
    and Rebirth.IsProperlySummoned(tc) and tc:IsCode(base_id)
end
function Rebirth.EvoCandFilter(tc,sg,mg_std,f_prime,grade,cur_sum)
    if #sg==0 and f_prime(tc) then return true end
    if not mg_std:IsContains(tc) then return false end
    local v=Rebirth.GetMaterialValue(tc)
    local rem=grade-cur_sum
    if v<=0 or v>rem then return false end
    if v==rem then return true end
    local test_g=mg_std:Clone()
    test_g:Sub(sg)
    test_g:RemoveCard(tc)
    return Rebirth.FastCanSum(test_g,rem-v,1,grade-#sg-1,Rebirth.GetMaterialValue)
end
function Rebirth.EvolutionTarget(grade,material_filter,filter)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,c)
        local f_prime=Rebirth.GetEvoFilter(material_filter)
        if chk==0 then return Rebirth.EvolutionCondition(grade,material_filter,filter)(e,c) end
        local mg_prime=Duel.GetMatchingGroup(f_prime,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
        local mg_std=Duel.GetMatchingGroup(Rebirth.TraceFilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,c,filter,false)
        local mg=mg_std+mg_prime
        local sg=Group.CreateGroup()
        local cancelable=Duel.IsSummonCancelable()
        while #sg<grade do
            local cur_sum=sg:GetSum(Rebirth.GetMaterialValue)
            local is_prime=(#sg==1 and f_prime(sg:GetFirst()))
            local finish=is_prime or (cur_sum==grade and #sg>=1)
            local cg=Group.CreateGroup()
            if not is_prime then
                cg=mg:Filter(Rebirth.EvoCandFilter,sg,sg,mg_std,f_prime,grade,cur_sum)
            end
            if #cg==0 and not finish then break end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
            local tc=Group.SelectUnselect(cg,sg,tp,finish,cancelable and #sg==0,1,1)
            if not tc then break end
            if not sg:IsContains(tc) then sg:AddCard(tc) else sg:RemoveCard(tc) end
        end
        if #sg>0 and ((#sg==1 and f_prime(sg:GetFirst())) or sg:GetSum(Rebirth.GetMaterialValue)==grade) then
            sg:KeepAlive()
            e:SetLabelObject(sg)
            e:SetLabel((#sg==1 and f_prime(sg:GetFirst())) and 1 or 0)
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
function Rebirth.TraceFilter_Mix(tc,c,filter)
    local loc=(tc:IsLocation(LOCATION_GRAVE) or tc:IsLocation(LOCATION_REMOVED))
    if not (loc and tc:IsType(TYPE_MONSTER)) then return false end
	if not Rebirth.IsProperlySummoned(tc) then return false end
    if not tc:IsHasEffect(EFFECT_REBIRTH_GRADE) then return false end  
    if filter and type(filter)=="function" and not filter(tc,c) then 
        return false 
    end  
    return true
end
function Rebirth.GetMixValue(tc)
    if not tc then return 0 end
    local eff=tc:IsHasEffect(EFFECT_REBIRTH_GRADE)
    if eff then
        local val=eff:GetValue()
        return (type(val)=="function" and val(eff,tc) or val) or 0
    end
    return tc:GetOriginalLevel() or 0
end
function Rebirth.TraceFilter_ValueSum(tc,c,filter)
    local loc=(tc:IsLocation(LOCATION_GRAVE) or tc:IsLocation(LOCATION_REMOVED))
    if not (loc and tc:IsType(TYPE_MONSTER)) then return false end
	if not Rebirth.IsProperlySummoned(tc) then return false end	
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
	local min=min or 1
    local max=max or 99
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
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
        local mg=Duel.GetMatchingGroup(Rebirth.TraceFilter_Mix,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,c,filter)               
        return Rebirth.FastCanSum(mg,target_grade,min,max,Rebirth.GetMixValue)
	end
end
function Rebirth.GenericTarget(min,max,filter)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,c)
        if chk==0 then return Rebirth.GenericCondition(min,max,filter)(e,c) end        
        local eff=c:IsHasEffect(EFFECT_REBIRTH_GRADE)
        local target_grade=eff and eff:GetValue() or c:GetOriginalLevel()
        local cancelable=Duel.IsSummonCancelable()
        local mg=Duel.GetMatchingGroup(Rebirth.TraceFilter_Mix,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,c,filter)        
        local sg=Rebirth.SelectMaterials(mg,tp,target_grade,min,max,Rebirth.GetMixValue,cancelable,HINTMSG_CONFIRM)
		if sg then
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
function Rebirth.AddCombinationProcedure(c,min,max,filter,special_con,grade)
	local min=min or 2
	local max=max or 99
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Rebirth.CombinationCondition(min,max,filter,special_con))
	e1:SetTarget(Rebirth.CombinationTarget(min,max,filter,special_con))
	e1:SetOperation(Rebirth.Operation)
	e1:SetValue(SUMMON_TYPE_REBIRTH)
	c:RegisterEffect(e1)

	Rebirth.AddCommonEffects(c,grade or c:GetOriginalLevel())
end
function Rebirth.TraceFilter_Combination(tc,c,filter)
    local loc=(tc:IsLocation(LOCATION_GRAVE) or tc:IsLocation(LOCATION_REMOVED))
    if not (loc and tc:IsType(TYPE_MONSTER)) then return false end
	if not Rebirth.IsProperlySummoned(tc) then return false end
    if filter and type(filter)=="function" and not filter(tc,c) then 
        return false 
    end  
    local has_grade=tc:IsHasEffect(EFFECT_REBIRTH_GRADE)
    local has_level=tc:GetOriginalLevel()>0 or tc:GetLevel()>0  
    return has_grade or has_level
end
function Rebirth.CombinationCondition(min,max,filter,special_con)
    return function(e,c)
        if c==nil then return true end
        local tp=c:GetControler()
        local eff=c:IsHasEffect(EFFECT_REBIRTH_GRADE)
        local target_grade=eff and eff:GetValue() or c:GetOriginalLevel()              
        if Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then return false end       
        local mg=Duel.GetMatchingGroup(Rebirth.TraceFilter_Combination,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,c,filter)                       
        if special_con and not special_con(e,tp,mg) then return false end                           
        return Rebirth.FastCanSumCombo(mg,target_grade,min,max)
	end
end
function Rebirth.ComboCandFilter(tc,sg,rem_g,grade,min,eff_max)
    local test_sg=sg:Clone()
    test_sg:AddCard(tc)
    local cur_sum=test_sg:GetSum(Rebirth.GetMixValue)
    if cur_sum>grade then return false end
    local has_g=test_sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_REBIRTH_GRADE)
    local has_l=test_sg:IsExists(aux.NOT(Card.IsHasEffect),1,nil,EFFECT_REBIRTH_GRADE)
    local cur_state=(has_g and 2 or 0)|(has_l and 1 or 0)
    if cur_sum==grade then
        return #test_sg>=min and cur_state==3
    end
    local rem_min=math.max(1,min-#test_sg)
    local rem_max=eff_max-#test_sg
    if rem_max<=0 then return false end
    local next_g=rem_g:Clone()
    next_g:RemoveCard(tc)
    return Rebirth.FastCanSumCombo(next_g,grade-cur_sum,rem_min,rem_max,cur_state)
end
function Rebirth.CombinationTarget(min,max,filter,special_con)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,c)
        if chk==0 then return Rebirth.CombinationCondition(min,max,filter,special_con)(e,c) end
        local eff=c:IsHasEffect(EFFECT_REBIRTH_GRADE)
        local grade=eff and eff:GetValue() or c:GetOriginalLevel()
        local mg=Duel.GetMatchingGroup(Rebirth.TraceFilter_Combination,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,c,filter)
        local sg=Group.CreateGroup()
        local cancelable=Duel.IsSummonCancelable()
        local eff_max=math.min(max or 99,grade)
        while #sg<eff_max do
            local has_g=sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_REBIRTH_GRADE)
            local has_l=sg:IsExists(aux.NOT(Card.IsHasEffect),1,nil,EFFECT_REBIRTH_GRADE)
            local finish=(sg:GetSum(Rebirth.GetMixValue)==grade and #sg>=min and has_g and has_l)
            local rem_g=mg:Clone()
            rem_g:Sub(sg)
            local cg=rem_g:Filter(Rebirth.ComboCandFilter,nil,sg,rem_g,grade,min,eff_max)
            if #cg==0 and not finish then break end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
            local tc=Group.SelectUnselect(cg,sg,tp,finish,cancelable and #sg==0,1,1)
            if not tc then break end
            if not sg:IsContains(tc) then sg:AddCard(tc) else sg:RemoveCard(tc) end
        end
        local has_g=sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_REBIRTH_GRADE)
        local has_l=sg:IsExists(aux.NOT(Card.IsHasEffect),1,nil,EFFECT_REBIRTH_GRADE)
        if #sg>=min and sg:GetSum(Rebirth.GetMixValue)==grade and has_g and has_l then
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
function Rebirth.AddCommonEffects(c,grade)
	Rebirth.InitGlobalTracker()
    c:SetStatus(STATUS_NO_LEVEL,true)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
    e0:SetRange(LOCATION_ALL)
    e0:SetCode(EFFECT_REMOVE_TYPE)
    e0:SetValue(TYPE_FUSION)
    c:RegisterEffect(e0)   
    local e1=Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
    e1:SetRange(LOCATION_ALL)
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