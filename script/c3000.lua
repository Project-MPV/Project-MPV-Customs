local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x7971),Fusion.InHandMat(Card.IsAbleToDeck),s.fextra,Fusion.ShuffleMaterial)
	c:RegisterEffect(e1)
end
s.listed_series={0x7971}
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToDeck,Card.IsFaceup),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
end
