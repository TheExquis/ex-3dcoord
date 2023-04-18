local isActive = false
local function RotationToDirection(rotation)
    local adjustedRotation =
    {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction =
    {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

local function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination =
    {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x
        , destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, c, e
end

RegisterCommand('3dcoords',function ()
    isActive = not isActive
    while isActive do
        local plyCoords = GetEntityCoords(PlayerPedId())
        local hit, coords, entity = RayCastGamePlayCamera(1000.0)
        if hit then
            DrawLine(plyCoords.x, plyCoords.y, plyCoords.z, coords.x, coords.y, coords.z, 0, 255, 0, 100)
            DrawSphere(coords.x, coords.y, coords.z,0.5,0,255,0,0.8)
            -- Only draw of not center of map
        elseif coords.x ~= 0.0 and coords.y ~= 0.0 then
            -- Draws line to targeted position
            DrawLine(plyCoords.x, plyCoords.y, plyCoords.z, coords.x, coords.y, coords.z, 0, 255, 0, 100)
            DrawSphere(coords.x, coords.y, coords.z,0.5,0,255,0,0.8)
        end
        if IsControlJustPressed(0,38) then
            lib.setClipboard('vec3('..coords.x..','..coords.y..','..coords.z..')')
            lib.notify({
                title = '3D Coord',
                description = 'Successfully Copied the coords',
                type = 'success'
            })
        end
        Wait(0)
    end
end,false)