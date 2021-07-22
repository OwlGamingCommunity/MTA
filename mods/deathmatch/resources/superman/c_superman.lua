-- Copyright (c) 2008, Alberto Alonso
--
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--
--     * Redistributions of source code must retain the above copyright notice, this
--       list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright notice, this
--       list of conditions and the following disclaimer in the documentation and/or other
--       materials provided with the distribution.
--     * Neither the name of the superman script nor the names of its contributors may be used
--       to endorse or promote products derived from this software without specific prior
--       written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
-- A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
-- PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
-- LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
-- NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
local Superman = {}

function canceldamage()
	cancelEvent()
end
addEventHandler("onClientPedDamage", getRootElement(), canceldamage)

-- Settings
local ZERO_TOLERANCE = 0.00001
local MAX_ANGLE_SPEED = 6 -- In degrees per frame
local MAX_SPEED = 1.0
local EXTRA_SPEED_FACTOR = 1.95
local LOW_SPEED_FACTOR = 0.40
local ACCELERATION = 0.025
local EXTRA_ACCELERATION_FACTOR = 2
local LOW_ACCELERATION_FACTOR = 0.85
local TAKEOFF_VELOCITY = 1.75
local TAKEOFF_FLIGHT_DELAY = 750
local SMOKING_SPEED = 1000
local GROUND_ZERO_TOLERANCE = 0.18
local LANDING_DISTANCE = 3.2
local FLIGHT_ANIMLIB = "swim"
local FLIGHT_ANIMATION = "Swim_Dive_Under"
local FLIGHT_ANIM_LOOP = false
local IDLE_ANIMLIB = "cop_ambient"
local IDLE_ANIMATION = "Coplook_loop"
local IDLE_ANIM_LOOP = true
local MAX_Y_ROTATION = 70
local ROTATION_Y_SPEED = 3.8

-- Static global variables
local thisResource = getThisResource()
local rootElement = getRootElement()
local localPlayer = getLocalPlayer()
local serverGravity = getGravity()

--
-- vG Custom
--
local function canFly()
	-- admins not in parachute mode
  return (exports.integration:isPlayerTrialAdmin(localPlayer, true) or (exports.global:isPlayerScripter(localPlayer)) or getElementData(localPlayer, "canFly")) and not getElementData(localPlayer, "parachuting")  and not getElementData(localPlayer, "parachuting")
end

--
-- Utility functions
--
local function isPlayerFlying(player)
  local data = getElementData(player, "superman:flying")
  if not data or data == false then return false
  else return true end
end

local function setPlayerFlying(player, state)
  if state == true then state = true
  else state = false end

  setElementData(player, "superman:flying", state)
end

local function iterateFlyingPlayers()
  local current = 1
  local allPlayers = getElementsByType("player")

  return function()
    local player
    
    repeat
      player = allPlayers[current]
      current = current + 1
    until not player or (isPlayerFlying(player) and isElementStreamedIn(player))

    return player
  end
end

function Superman:restorePlayer(player)
  setPlayerFlying(player, false)
  setPedAnimation(player, false)
  setElementVelocity(player, 0, 0, 0)
  setElementRotation(player, 0, 0, 0)
  --setPedRotation(player, getPedRotation(player))
  setElementCollisionsEnabled(player, true)
  self:destroySmokeGenerators(player)
  self.rotations[player] = nil
  self.previousVelocity[player] = nil
end

function Superman:createSmokeGenerator(player)
  local generator = createObject(2780, getElementPosition(player))
  setElementCollisionsEnabled(generator, false)
  setObjectScale(generator, 0)
  return generator
end

function Superman:createSmokeGenerators(player)
  if not self.smokeGenerators[player] then
    local smokeGenerators = {}

    smokeGenerators[1] = self:createSmokeGenerator(player)
    attachElements(smokeGenerators[1], player, 0.75, -0.2, -0.4, -40, 0, 60)
    smokeGenerators[2] = self:createSmokeGenerator(player)
    attachElements(smokeGenerators[2], player, -0.75, -0.2, -0.4, -40, 0, -60)

    self.smokeGenerators[player] = smokeGenerators
  end
end

function Superman:destroySmokeGenerators(player)
  if self.smokeGenerators[player] then
    for k, v in ipairs(self.smokeGenerators[player]) do
      destroyElement(v)
    end
    self.smokeGenerators[player] = nil
  end
end

function angleDiff(angle1, angle2)
  angle1, angle2 = angle1 % 360, angle2 % 360
  local diff = (angle1 - angle2) % 360
  if diff <= 180 then
    return diff
  else
    return -(360 - diff)
  end
end

local function isElementInWater(ped)
  local pedPosition = Vector3D:new(getElementPosition(ped))
  if pedPosition.z <= 0 then return true end

  local waterLevel = getWaterLevel(pedPosition.x, pedPosition.y, pedPosition.z)
  if not isElementStreamedIn(ped) or not waterLevel or waterLevel < pedPosition.z then
    return false
  else
    return true
  end
end

local function isnan(x)
	math.inf = 1/0
	if x == math.inf or x == -math.inf or x ~= x then
		return true
	end
	return false
end

local function getVector2DAngle(vec)
  if vec.x == 0 and vec.y == 0 then return 0 end
  local angle = math.deg(math.atan(vec.x / vec.y)) + 90
  if vec.y < 0 then
    angle = angle + 180
  end
  return angle
end

--
-- Initialization and shutdown functions
--
function Superman.Start()
  local self = Superman

  -- Register events
  addEventHandler("onClientResourceStop", getResourceRootElement(thisResource), Superman.Stop, false)
  addEventHandler("onPlayerJoin", rootElement, Superman.onJoin)
  addEventHandler("onPlayerQuit", rootElement, Superman.onQuit)
  addEventHandler("onClientRender", rootElement, Superman.processControls)
  addEventHandler("onClientRender", rootElement, Superman.processFlight)
  addEventHandler("onClientPlayerDamage", localPlayer, Superman.onDamage, false)
  addEventHandler("onClientElementDataChange", rootElement, Superman.onDataChange)
  addEventHandler("onClientElementStreamIn", rootElement, Superman.onStreamIn)
  addEventHandler("onClientElementStreamOut", rootElement, Superman.onStreamOut)

  -- Bind keys
  --bindKey("jump", "down", Superman.onJump)

  -- Register commands
  addCommandHandler("superman", Superman.cmdSuperman)

  -- Initializate attributes
  self.smokeGenerators = {}
  self.rotations = {}
  self.previousVelocity = {}
end
addEventHandler("onClientResourceStart", getResourceRootElement(thisResource), Superman.Start, false)

function Superman.Stop()
  local self = Superman

  setGravity(serverGravity)

  -- Restore all players animations, collisions, etc
  for player in iterateFlyingPlayers() do
    self:restorePlayer(player)
  end
end



--
-- Join/Quit
--
function Superman.onJoin(player)
  local self = Superman
  local player = player or source

  setPlayerFlying(player, false)
end

function Superman.onQuit(reason, player)
  local self = Superman
  local player = player or source

  if isPlayerFlying(player) then
    self:restorePlayer(player)
  end
end


--
-- onDamage: superman is invulnerable
--
function Superman.onDamage()
  local self = Superman

  if isPlayerFlying(localPlayer) then
    cancelEvent()
  end
end


--
-- onStreamIn: Reset rotation attribute for player
--
function Superman.onStreamIn()
  local self = Superman
end

function Superman.onStreamOut()
  local self = Superman

  if source and isElement(source) and getElementType(source) == "player" and isPlayerFlying(source) then
    self.rotations[source] = nil
    self.previousVelocity[source] = nil
  end
end

--
-- onDataChange: Check if somebody who is out of stream stops being superman
--
function Superman.onDataChange(dataName, oldValue)
  local self = Superman

  if dataName == "superman:flying" and isElement(source) and getElementType(source) == "player" and
     oldValue ~= getElementData(source, dataName) and oldValue == true and getElementData(source, dataName) == false then
    self:restorePlayer(source)
  end
end

--
-- onJump: Combo to start flight without any command
--
function Superman.onJump(key, keyState)
  if not canFly() then return end -- vG custom
  
  local self = Superman

  local task = getPedSimplestTask(localPlayer)
  if not isPlayerFlying(localPlayer) then
    if task == "TASK_SIMPLE_IN_AIR" then
      setElementVelocity(localPlayer, 0, 0, TAKEOFF_VELOCITY)
      setTimer(Superman.startFlight, 100, 1)
    end
  end
end

--
-- Commands
--
function Superman.cmdSuperman()
  if not canFly() then return end -- vG custom
  
  local self = Superman

  if isPedInVehicle(localPlayer) or isPlayerFlying(localPlayer) then return end
  setElementVelocity(localPlayer, 0, 0, TAKEOFF_VELOCITY)
  setTimer(Superman.startFlight, TAKEOFF_FLIGHT_DELAY, 1)
end

function Superman.startFlight()
  local self = Superman

  if isPlayerFlying(localPlayer) then return end

  triggerServerEvent("superman:start", rootElement)
  setPlayerFlying(localPlayer, true)
  setElementVelocity(localPlayer, 0, 0, 0)
  self.currentSpeed = 0
  self.extraVelocity = { x = 0, y = 0, z = 0 }
end


--
-- Controls processing
--
local jump, oldJump = false, false
function Superman.processControls()
  local self = Superman

  -- vG custom
  if not isPlayerFlying(localPlayer) then
    jump, oldJump = getPedControlState(localPlayer, "jump"), jump
    if canFly() and not oldJump and jump then 
      Superman.onJump()
    end
    return
  end
  -- if not isPlayerFlying(localPlayer) then return end

  -- Calculate the requested movement direction
  local Direction = Vector3D:new(0, 0, 0)
  if getPedControlState(localPlayer, "forwards") then
    Direction.y = 1
  elseif getPedControlState(localPlayer, "backwards") then
    Direction.y = -1
  end

  if getPedControlState(localPlayer, "left") then
    Direction.x = 1
  elseif getPedControlState(localPlayer, "right") then
    Direction.x = -1
  end
  Direction:Normalize()

  -- Calculate the sight direction
  local cameraX, cameraY, cameraZ, lookX, lookY, lookZ = getCameraMatrix()
  local SightDirection = Vector3D:new((lookX - cameraX), (lookY - cameraY), (lookZ - cameraZ))
  SightDirection:Normalize()
  if getPedControlState(localPlayer, "look_behind") then
    SightDirection = SightDirection:Mul(-1)
  end

  -- Calculate the current max speed and acceleration values
  local maxSpeed = MAX_SPEED
  local acceleration = ACCELERATION
  if getPedControlState(localPlayer, "sprint") then
    maxSpeed = MAX_SPEED * EXTRA_SPEED_FACTOR
    acceleration = acceleration * EXTRA_ACCELERATION_FACTOR
  elseif getPedControlState(localPlayer, "walk") then
    maxSpeed = MAX_SPEED * LOW_SPEED_FACTOR
    acceleration = acceleration * LOW_ACCELERATION_FACTOR
  end

  local DirectionModule = Direction:Module()

  -- Check if we must change the gravity
  if DirectionModule == 0 and self.currentSpeed ~= 0 then
    setGravity(0)
  else
    setGravity(serverGravity)
  end

  -- Calculate the new current speed
  if self.currentSpeed ~= 0 and (DirectionModule == 0 or self.currentSpeed > maxSpeed) then
    -- deccelerate
    self.currentSpeed = self.currentSpeed - acceleration
    if self.currentSpeed < 0 then self.currentSpeed = 0 end

  elseif DirectionModule ~= 0 and self.currentSpeed < maxSpeed then
    -- accelerate
    self.currentSpeed = self.currentSpeed + acceleration
    if self.currentSpeed > maxSpeed then self.currentSpeed = maxSpeed end

  end

  -- Calculate the movement requested direction
  if DirectionModule ~= 0 then
    Direction = Vector3D:new(SightDirection.x * Direction.y - SightDirection.y * Direction.x,
                             SightDirection.x * Direction.x + SightDirection.y * Direction.y,
                             SightDirection.z * Direction.y)
    -- Save the last movement direction for when player releases all direction keys
    self.lastDirection = Direction
  else
    -- Player is not specifying any direction, use last known direction or the current velocity
    if self.lastDirection then
      Direction = self.lastDirection
      if self.currentSpeed == 0 then self.lastDirection = nil end
    else
      Direction = Vector3D:new(getElementVelocity(localPlayer))
    end
  end
  Direction:Normalize()
  Direction = Direction:Mul(self.currentSpeed)

  -- Applicate a smooth direction change, if moving
  if self.currentSpeed > 0 then
    local VelocityDirection = Vector3D:new(getElementVelocity(localPlayer))
    VelocityDirection:Normalize()

    if math.sqrt(VelocityDirection.x^2 + VelocityDirection.y^2) > 0 then
      local DirectionAngle = getVector2DAngle(Direction)
      local VelocityAngle = getVector2DAngle(VelocityDirection)

      local diff = angleDiff(DirectionAngle, VelocityAngle)
      local calculatedAngle

      if diff >= 0 then 
        if diff > MAX_ANGLE_SPEED then
          calculatedAngle = VelocityAngle + MAX_ANGLE_SPEED
	else
	  calculatedAngle = DirectionAngle
	end
      else
        if diff < MAX_ANGLE_SPEED then
          calculatedAngle = VelocityAngle - MAX_ANGLE_SPEED
	else
          calculatedAngle = DirectionAngle
        end
      end
      calculatedAngle = calculatedAngle % 360

      local DirectionModule2D = math.sqrt(Direction.x^2 + Direction.y^2)
      Direction.x = -DirectionModule2D*math.cos(math.rad(calculatedAngle))
      Direction.y = DirectionModule2D*math.sin(math.rad(calculatedAngle))
    end
  end

  if Direction:Module() == 0 then
	self.extraVelocity = { x = 0, y = 0, z = 0 }
  end
  
  -- Set the new velocity
  setElementVelocity(localPlayer, Direction.x + self.extraVelocity.x,
                                  Direction.y + self.extraVelocity.y,
								  Direction.z + self.extraVelocity.z)

  if self.extraVelocity.z > 0 then
    self.extraVelocity.z = self.extraVelocity.z - 1
	if self.extraVelocity.z < 0 then self.extraVelocity.z = 0 end
  elseif self.extraVelocity.z < 0 then
	self.extraVelocity.z = self.extraVelocity.z + 1
	if self.extraVelocity.z > 0 then self.extraVelocity.z = 0 end
  end
end



--
-- Players flight processing
--
function Superman.processFlight()
  local self = Superman

  for player in iterateFlyingPlayers() do
    local Velocity = Vector3D:new(getElementVelocity(player))
    local distanceToBase = getElementDistanceFromCentreOfMassToBaseOfModel(player)
    local playerPos = Vector3D:new(getElementPosition(player))
    playerPos.z = playerPos.z - distanceToBase

    local distanceToGround
    if playerPos.z > 0 then
      local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(playerPos.x, playerPos.y, playerPos.z,
                                                                   playerPos.x, playerPos.y, playerPos.z - LANDING_DISTANCE - 1,
                                                                   true, true, true, true, true, false, false, false)
      if hit then distanceToGround = playerPos.z - hitZ end
    end

    if distanceToGround and distanceToGround < GROUND_ZERO_TOLERANCE then
      self:restorePlayer(player)
      if player == localPlayer then
      	setGravity(serverGravity)
        triggerServerEvent("superman:stop", getRootElement())
      end
    elseif distanceToGround and distanceToGround < LANDING_DISTANCE then
      self:processLanding(player, Velocity, distanceToGround)
    elseif Velocity:Module() < ZERO_TOLERANCE then
      self:processIdleFlight(player)
    else
      self:processMovingFlight(player, Velocity)
    end
  end
end

function Superman:processIdleFlight(player)
  -- Set the proper animation on the player
  local animLib, animName = getPedAnimation(player)
  if animLib ~= IDLE_ANIMLIB or animName ~= IDLE_ANIMATION then
    setPedAnimation(player, IDLE_ANIMLIB, IDLE_ANIMATION, -1, IDLE_ANIM_LOOP, false, false)
  end

  setElementCollisionsEnabled(player, false)

  -- If this is myself, calculate the ped rotation depending on the camera rotation
  if player == localPlayer then
    local cameraX, cameraY, cameraZ, lookX, lookY, lookZ = getCameraMatrix()
    local Sight = Vector3D:new(lookX - cameraX, lookY - cameraY, lookZ - cameraZ)
    Sight:Normalize()
    if getPedControlState(localPlayer, "look_behind") then
      Sight = Sight:Mul(-1)
    end

    Sight.z = math.atan(Sight.x / Sight.y)
    if Sight.y > 0 then
      Sight.z = Sight.z + math.pi
    end
    Sight.z = math.deg(Sight.z) + 180

    setPedRotation(localPlayer, Sight.z)
    setElementRotation(localPlayer, 0, 0, Sight.z)
  else
    local Zangle = getPedCameraRotation(player)
    setPedRotation(player, Zangle)
    setElementRotation(player, 0, 0, Zangle)
  end
end

function Superman:processMovingFlight(player, Velocity)
  -- Set the proper animation on the player
  local animLib, animName = getPedAnimation(player)
  if animLib ~= FLIGHT_ANIMLIB or animName ~= FLIGHT_ANIMATION then
    setPedAnimation(player, FLIGHT_ANIMLIB, FLIGHT_ANIMATION, -1, FLIGHT_ANIM_LOOP, true, false)
  end

  if player == localPlayer then
    setElementCollisionsEnabled(player, true)
  else
    setElementCollisionsEnabled(player, false)
  end

  -- Calculate the player rotation depending on their velocity
  local Rotation = Vector3D:new(0, 0, 0)
  if Velocity.x == 0 and Velocity.y == 0 then
    Rotation.z = getPedRotation(player)
  else
    Rotation.z = math.deg(math.atan(Velocity.x / Velocity.y))
    if Velocity.y > 0 then
      Rotation.z = Rotation.z - 180
    end
    Rotation.z = (Rotation.z + 180) % 360
  end
  Rotation.x = -math.deg(Velocity.z / Velocity:Module() * 1.2)

  -- Rotation compensation for the self animation rotation
  Rotation.x = Rotation.x - 40

  -- Calculate the Y rotation for barrel rotations
  if not self.rotations[player] then self.rotations[player] = 0 end
  if not self.previousVelocity[player] then self.previousVelocity[player] = Vector3D:new(0, 0, 0) end
  
  local previousAngle = getVector2DAngle(self.previousVelocity[player])
  local currentAngle = getVector2DAngle(Velocity)
  local diff = angleDiff(currentAngle, previousAngle)
  if isnan(diff) then
	diff = 0
  end
  local calculatedYRotation = -diff * MAX_Y_ROTATION / MAX_ANGLE_SPEED

  if calculatedYRotation > self.rotations[player] then
    if calculatedYRotation - self.rotations[player] > ROTATION_Y_SPEED then
      self.rotations[player] = self.rotations[player] + ROTATION_Y_SPEED
    else
      self.rotations[player] = calculatedYRotation
    end
  else
    if self.rotations[player] - calculatedYRotation > ROTATION_Y_SPEED then
      self.rotations[player] = self.rotations[player] - ROTATION_Y_SPEED
    else
      self.rotations[player] = calculatedYRotation
    end
  end

  if self.rotations[player] > MAX_Y_ROTATION then
    self.rotations[player] = MAX_Y_ROTATION
  elseif self.rotations[player] < -MAX_Y_ROTATION then
    self.rotations[player] = -MAX_Y_ROTATION
  elseif math.abs(self.rotations[player]) < ZERO_TOLERANCE then
    self.rotations[player] = 0
  end
  Rotation.y = self.rotations[player]

  -- Apply the calculated rotation
  setPedRotation(player, Rotation.z)
  setElementRotation(player, Rotation.x, Rotation.y, Rotation.z)

  -- Save the current velocity
  self.previousVelocity[player] = Velocity

  -- If the speed is over the given value, create the smoke generators
  if Velocity:Module() > (SMOKING_SPEED - ZERO_TOLERANCE) and not isElementInWater(player) then
    self:createSmokeGenerators(player)
  else
    self:destroySmokeGenerators(player)
  end
end

function Superman:processLanding(player, Velocity, distanceToGround)
  -- Set the proper animation on the player
  local animLib, animName = getPedAnimation(player)
  if animLib ~= FLIGHT_ANIMLIB or animName ~= FLIGHT_ANIMATION then
    setPedAnimation(player, FLIGHT_ANIMLIB, FLIGHT_ANIMATION, -1, FLIGHT_ANIM_LOOP, true, false)
  end

  if player == localPlayer then
    setElementCollisionsEnabled(player, true)
  else
    setElementCollisionsEnabled(player, false)
  end

  -- If the speed is over the given value, create the smoke generators
  if Velocity:Module() > (SMOKING_SPEED - ZERO_TOLERANCE) and not isElementInWater(player) then
    self:createSmokeGenerators(player)
  else
    self:destroySmokeGenerators(player)
  end

  -- Calculate the player rotation depending on their velocity and distance to ground
  local Rotation = Vector3D:new(0, 0, 0)
  if Velocity.x == 0 and Velocity.y == 0 then
    Rotation.z = getPedRotation(player)
  else
    Rotation.z = math.deg(math.atan(Velocity.x / Velocity.y))
    if Velocity.y > 0 then
      Rotation.z = Rotation.z - 180
    end
    Rotation.z = (Rotation.z + 180) % 360
  end
  Rotation.x = -(85 - (distanceToGround * 85 / LANDING_DISTANCE))

  -- Rotation compensation for the self animation rotation
  Rotation.x = Rotation.x - 40

  -- Apply the calculated rotation
  setPedRotation(player, Rotation.z)
  setElementRotation(player, Rotation.x, Rotation.y, Rotation.z)
end



--
-- Vectors
--
Vector3D = {
  new = function(self, _x, _y, _z)
    local newVector = { x = _x or 0.0, y = _y or 0.0, z = _z or 0.0 }
    return setmetatable(newVector, { __index = Vector3D })
  end,

  Copy = function(self)
    return Vector3D:new(self.x, self.y, self.z)
  end,

  Normalize = function(self)
    local mod = self:Module()
    if mod ~= 0 then
      self.x = self.x / mod
      self.y = self.y / mod
      self.z = self.z / mod
    end
  end,

  Dot = function(self, V)
    return self.x * V.x + self.y * V.y + self.z * V.z
  end,

  Module = function(self)
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
  end,

  AddV = function(self, V)
    return Vector3D:new(self.x + V.x, self.y + V.y, self.z + V.z)
  end,

  SubV = function(self, V)
    return Vector3D:new(self.x - V.x, self.y - V.y, self.z - V.z)
  end,

  CrossV = function(self, V)
    return Vector3D:new(self.y * V.z - self.z * V.y,
                        self.z * V.x - self.x * V.z,
                        self.x * V.y - self.y * V.z)
  end,

  Mul = function(self, n)
    return Vector3D:new(self.x * n, self.y * n, self.z * n)
  end,

  Div = function(self, n)
    return Vector3D:new(self.x / n, self.y / n, self.z / n)
  end,

  MulV = function(self, V)
    return Vector3D:new(self.x * V.x, self.y * V.y, self.z * V.z)
  end,

  DivV = function(self, V)
    return Vector3D:new(self.x / V.x, self.y / V.y, self.z / V.z)
  end,
}

