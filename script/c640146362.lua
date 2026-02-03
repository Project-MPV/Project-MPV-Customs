--Enigmation Wonder Fountain
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Recycle + Apply Effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DISABLE+CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--If this card is banished
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.bntg)
	e2:SetOperation(s.bnop)
	c:RegisterEffect(e2)
end
s.listed_series={0x344}
s.listed_names={96488218,96488216,96488199}
function s.recfilter(c)
    return c:IsSetCard(0x344) and c:IsMonster() and c:IsAbleToDeck()
end
function s.monfilter(c)
    return c:IsFaceup() and (c:IsCode(96488218,96488216,96488199) or c:ListsCode(96488218,96488216,96488199))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then return Duel.IsExistingTarget(s.recfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
        and Duel.IsExistingTarget(s.monfilter,tp,LOCATION_MZONE,0,1,nil) end    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g1=Duel.SelectTarget(tp,s.recfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g2=Duel.SelectTarget(tp,s.monfilter,tp,LOCATION_MZONE,0,1,1,nil)    
    e:SetLabelObject(g2:GetFirst())
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g<2 then return end   
    local tc1=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE+LOCATION_REMOVED):GetFirst()
    local tc2=e:GetLabelObject() 
    if tc1 and Duel.SendtoDeck(tc1,nil,2,REASON_EFFECT)>0 and tc1:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
        if not tc2 or tc2:IsFacedown() or not tc2:IsRelateToEffect(e) then return end                
        local code=tc2:GetOriginalCode()        
        -- APPLY EFFECT (Ignoring Cost & Condition)     
        --SPECTRE DRAGON
        if code==96488199 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
            local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
            local sc=g:GetFirst()
            if sc then
                Duel.HintSelection(g)
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(-800)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                sc:RegisterEffect(e1)
                local e2=e1:Clone()
                e2:SetCode(EFFECT_UPDATE_DEFENSE)
                sc:RegisterEffect(e2)
                local e3=Effect.CreateEffect(e:GetHandler())
                e3:SetType(EFFECT_TYPE_SINGLE)
                e3:SetCode(EFFECT_DISABLE)
                e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                sc:RegisterEffect(e3)
                Duel.Damage(1-tp,800,REASON_EFFECT)
            end            
        --SPECTRAL GENERAL
        elseif code==96488216 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
            local g=Duel.SelectMatchingCard(tp,s.sum,tp,0,LOCATION_MZONE,1,1,nil)
            local sc=g:GetFirst()
            if sc then
                Duel.HintSelection(g)
                local op=Duel.SelectOption(tp,aux.Stringid(code,3),aux.Stringid(code,2))
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(op==0 and EFFECT_SET_ATTACK_FINAL or EFFECT_SET_DEFENSE_FINAL)
                e1:SetValue((op==0 and sc:GetAttack() or sc:GetDefense())/2)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                sc:RegisterEffect(e1)
            end
        --OVERCHARGE DRAGON
        elseif code==96488218 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
            local g=Duel.SelectMatchingCard(tp,Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,1,nil)
            local sc=g:GetFirst()
            if sc then
                Duel.HintSelection(g)
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_DISABLE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                sc:RegisterEffect(e1)
                local atk=sc:GetAttack()
                local e2=Effect.CreateEffect(e:GetHandler())
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_SET_ATTACK_FINAL)
                e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                e2:SetValue(math.ceil(atk/2))
                sc:RegisterEffect(e2)
                Duel.Damage(1-tp,math.ceil(atk/2),REASON_EFFECT)
                local e3=Effect.CreateEffect(e:GetHandler())
                e3:SetType(EFFECT_TYPE_SINGLE)
                e3:SetCode(EFFECT_CANNOT_ATTACK)
                e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                sc:RegisterEffect(e3)
			end
           --SPECTRAL GENESIS
        elseif code==96488215 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
            local sg=Duel.SelectMatchingCard(tp,s.sum,tp,0,LOCATION_MZONE,1,1,nil)
            local sc=sg:GetFirst()
            if sc then
                Duel.HintSelection(sg)
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE) 
				e1:SetCode(EFFECT_SET_ATTACK_FINAL) 
				e1:SetValue(0)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                sc:RegisterEffect(e1)
                local e2=e1:Clone() 
				e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
                sc:RegisterEffect(e2)
            end			
        --OVER BURST DRAGON 
        elseif code==96488219 then
            local sg=Duel.GetMatchingGroup(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,nil)
			local sc=sg:GetFirst()
            for sc in aux.Next(sg) do
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE) 
				e1:SetCode(EFFECT_DISABLE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                sc:RegisterEffect(e1)
                local e2=e1:Clone() 
				e2:SetCode(EFFECT_SET_ATTACK_FINAL) 
				e2:SetValue(0)
                sc:RegisterEffect(e2)
                local e3=e1:Clone() 
				e3:SetCode(EFFECT_SET_DEFENSE_FINAL)
                sc:RegisterEffect(e3)
            end
            local count=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
            Duel.Damage(1-tp,count*500,REASON_EFFECT)			
        --PHANTASM DRAGON 
        elseif code==96488201 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
            if #sg>0 then
                Duel.HintSelection(sg)
                if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)>0 then
                    Duel.Damage(1-tp,1400,REASON_EFFECT)
					end
                end
            end
        end
    end
function s.sum(c)
    return c:IsFaceup() and (c:HasNonZeroAttack() or c:HasNonZeroDefense())
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_EXTRA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.bntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.bnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	if not sc then return end
	if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	sc:CompleteProcedure()
	if sc:IsType(TYPE_XYZ) then
		local mg=Group.FromCards(c)
		if Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,c) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local tc=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,c):GetFirst()
		if tc then
			mg:AddCard(tc)
		end
	end
		Duel.Overlay(sc,mg)
	end
end