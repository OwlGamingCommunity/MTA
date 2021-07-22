--Maxime
function getPropertyTaxRate(interiorType, faction)
	if not interiorType then
		interiorType = 0
	end
	local propertyTaxRate = 0.0005
	if interiorType == 1 or faction then
		propertyTaxRate = propertyTaxRate+0.0002
	end
	return propertyTaxRate
end
