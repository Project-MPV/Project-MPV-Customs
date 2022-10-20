--Blue-Eyes Prophesied Dragon
local s,id=GetID()
function s.initial_effect(c)
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x140),1,1,aux.FilterSummonCode(CARD_BLUEEYES_W_DRAGON),1,1)
	c:EnableReviveLimit()
--PendulumSummon
	Pendulum.AddProcedure(c)
end