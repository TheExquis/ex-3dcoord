local isActive = false
local selectedEntity = nil
local entityCoords = nil
local isActive3DCoords = false
-- Function to get the offset between two coordinates
local function GetCoordOffset(entity, targetCoords)
    local offset = GetOffsetFromEntityGivenWorldCoords(entity, targetCoords.x, targetCoords.y, targetCoords.z)
    return offset
end

-- Convert rotation to direction
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

-- Ray cast from game play camera
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

RegisterCommand('offsetfind', function()
    isActive = not isActive
    selectedEntity = nil
    entityCoords = nil
    
    while isActive do
        local hit, coords, entity = RayCastGamePlayCamera(1000.0)
        local plyCoords = GetEntityCoords(PlayerPedId())
        
        -- Draw line and sphere at the targeted position
        if hit then
            DrawLine(plyCoords.x, plyCoords.y, plyCoords.z, coords.x, coords.y, coords.z, 0, 255, 0, 100)
            DrawSphere(coords.x, coords.y, coords.z, 0.1, 0, 255, 0, 0.8)
        end
        
        -- Select entity with E key (key code 38)
        if IsControlJustPressed(0, 38) and hit and entity ~= 0 and selectedEntity == nil then
            selectedEntity = entity
            entityCoords = GetEntityCoords(selectedEntity)
            lib.notify({
                title = 'Entity Selected',
                description = 'Entity ID: ' .. entity .. ' - Now select a target point with F key',
                type = 'success'
            })
        end
        
        -- Display status text
        if selectedEntity == nil then
            BeginTextCommandDisplayHelp('STRING')
            AddTextComponentSubstringPlayerName('Press ~INPUT_CONTEXT~ to select an entity')
            EndTextCommandDisplayHelp(0, false, true, -1)
        else
            -- Draw marker at the selected entity position
            DrawMarker(0, entityCoords.x, entityCoords.y, entityCoords.z + 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                       0.5, 0.5, 0.5, 255, 0, 0, 200, false, false, 2, nil, nil, false)
                       
            BeginTextCommandDisplayHelp('STRING')
            AddTextComponentSubstringPlayerName('Press ~INPUT_ARREST~ to select target point and calculate offset')
            EndTextCommandDisplayHelp(0, false, true, -1)
            
            -- Select target point with F key (key code 23)
            if IsControlJustPressed(0, 49) and hit then
                local offset = GetCoordOffset(selectedEntity, coords)

                -- Format the offset for both vector3 and table formats
                local offsetVec3 = string.format('vec3(%.2f, %.2f, %.2f)', offset.x, offset.y, offset.z)
                
                -- Copy to clipboard
                lib.setClipboard(offsetVec3)
                
                lib.notify({
                    title = 'Offset Calculated',
                    description = 'Offset copied to clipboard: ' .. offsetVec3,
                    type = 'success'
                })
                
                -- Reset selection
                selectedEntity = nil
                entityCoords = nil
            end
        end
        
        -- Cancel with Backspace key (key code 177)
        if IsControlJustPressed(0, 177) then
            isActive = false
            lib.notify({
                title = 'Entity Offset',
                description = 'Command cancelled',
                type = 'error'
            })
        end
        
        Wait(0)
    end
end, false)

RegisterCommand('3dcoords', function()
    isActive3DCoords = not isActive3DCoords
    while isActive3DCoords do
        local plyCoords = GetEntityCoords(PlayerPedId())
        local hit, coords, entity = RayCastGamePlayCamera(1000.0)
        if hit then
            DrawLine(plyCoords.x, plyCoords.y, plyCoords.z, coords.x, coords.y, coords.z, 0, 255, 0, 100)
            DrawSphere(coords.x, coords.y, coords.z, 0.1, 0, 255, 0, 0.8)
            -- Only draw of not center of map
        elseif coords.x ~= 0.0 and coords.y ~= 0.0 then
            -- Draws line to targeted position
            DrawLine(plyCoords.x, plyCoords.y, plyCoords.z, coords.x, coords.y, coords.z, 0, 255, 0, 100)
            DrawSphere(coords.x, coords.y, coords.z, 0.1, 0, 255, 0, 0.8)
        end
        if IsControlJustPressed(0, 38) then
            lib.setClipboard('vec3(' .. coords.x .. ',' .. coords.y .. ',' .. coords.z .. ')')
            lib.notify({
                title = '3D Coord',
                description = 'Successfully Copied the coords',
                type = 'success'
            })
        end
        Wait(0)
    end
end, false)
