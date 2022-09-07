DUEL_LINKS_SKILL_COVER =   300000002

function Auxiliary.GetCharacter(c,coverNum)
    return SKILL_COVER+(coverNum*1000000)+(c:GetOriginalAttribute)+(c:GetOriginalRace())
end

function Auxiliary.AddDuelLinksSkillProcedure(c,coverNum,drawless,skillcon,skillop,countlimit)
	--activate
	local e1=Effect.CreateEffect(c) 
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(0x5f)
	e1:SetOperation(Auxiliary.SetSkillOp(coverNum,skillcon,skillop,countlimit,EVENT_FREE_CHAIN))
	c:RegisterEffect(e1)
	Auxiliary.AddDrawless(c,drawless)
end