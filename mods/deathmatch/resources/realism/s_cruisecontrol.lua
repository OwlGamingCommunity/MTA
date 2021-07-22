--[[function VehicleFixes()
    setModelHandling(568, "maxVelocity", 110) -- Sanchez
    setModelHandling(522, "maxVelocity", 160) -- NRG-500
    setModelHandling(510, "maxVelocity", 60) -- Mountain Bike
    setModelHandling(509, "maxVelocity", 55) -- Bike
    setModelHandling(481, "maxVelocity", 55) -- BMX
    setModelHandling(581, "maxVelocity", 140) -- BF-400
    setModelHandling(521, "maxVelocity", 150) -- FCR-900
    setModelHandlingd(521, "maxVelocity", 145) -- PCJ-600
    setModelHandlingd(463, "maxVelocity", 140) -- Freeway
    setModelHandlingd(486, "maxVelocity", 130) -- Wayfarer
    setModelHandlingd(448, "maxVelocity", 80) -- Pizzaboy
    setModelHandlingd(462, "maxVelocity", 90) -- Pizzaboy
    setModelHandlingd(471, "maxVelocity", 120) -- Quad
    setModelHandlingd(523, "maxVelocity", 160) -- HPV1000
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()),
     function()
         VehicleFixes()
         setTimer (VehicleFixes, 1000, 1)
end
)]]