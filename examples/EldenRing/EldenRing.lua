local utils = require("utils")

print("Elden Ring lua script loaded.")

onEffectStart(function (effect)
    print("Started effect " .. effect)

    if effect == "100 Runes" then
        addToVariable("Runes", 100)
    end
end)

onEffectEnd(function (effect)
    print("Ended effect " .. effect)
end)

onEffectTick(function (effect, dt)
    if effect == "Stamina Burst" then
        addToVariable("Stamina", 200 * dt)
    elseif effect == "Health Burst" then
        addToVariable("Health", 100 * dt)
    elseif effect == "Mana Burst" then
        addToVariable("Mana", 100 * dt)
        addToVariable("Health", -100 * dt)
    end
end)

-----------
-- Hooks --
-----------

local eldenringBase = resolvePointer("eldenring.exe")

local function getPlayerCharDataPtr()
    return resolvePointer("eldenring.exe 03B12E30 0 190 0 0")
end

-----------------------------------
-- Scale Stats by Activity Level --
-----------------------------------

hook( -- Endurance hook
    -- eldenring.exe+68C410 - 8B 41 44 - mov eax,[rcx+44] ; Read true endurance value.
    -- eldenring.exe+68C413 - C3       - ret 
    resolvePointer("eldenring.exe 68C413"),
    function ()
        if getModPaused() then return end
        RAX = math.floor(RAX * getActivityLevelSmoothed() * 2)
    end
)
-- ASM implementation. Keep for reference.
-- local pActivity = utils.allocateActivityVar(eldenringBase)
-- utils.createJumpHook({
--     address = resolvePointer("eldenring.exe 68C290"),
--     method = utils.hookMethods.int3,
--     nopCount = 3,
--     symbols = {pActivity = pActivity},
--     code = [[
--         pushfq
--             movsd xmm1, qword ptr [pActivity]   ; Load activity level into xmm1.
--             addsd xmm1, xmm1                    ; Multiply by 2.  
--             mov eax, [rcx + 0x44]               ; Read true endurance value.
--             cvtsi2sd xmm0, eax                  ; Load it into xmm0.
--             mulsd xmm0, xmm1                    ; Multiply by activity.
--             cvttsd2si eax, xmm0                 ; Convert back to int and store in eax.
--         popfq
--     ]]
-- })

hook( -- Vigor hook
    -- eldenring.exe+68C430 - 8B 41 3C - mov eax,[rcx+3C];
    -- eldenring.exe+68C433 - C3       - ret 
    resolvePointer("eldenring.exe 68C433"),
    function ()
        if getModPaused() then return end

        local activity = getActivityLevelSmoothed()
        local levels = 5
        activity = math.floor(activity * levels) / levels

        RAX = math.floor(RAX * activity)
    end
)

--------------------
-- Berserk effect --
--------------------

hook( -- Damage entity hook
-- eldenring.exe+437052 - 89 81 38010000 - mov [rcx+00000138],eax
resolvePointer( "eldenring.exe 437052" ),
function ()
    if getModPaused() then return end

    local entity = RCX
    if (entity == getPlayerCharDataPtr()) then return end -- This is the player entity, skip it.
    if ( readInt32(entity + 0x28) == 0) then return end   -- This might be torrent. Skip it too.

    local newHP = RAX
    local hp = readInt32(entity + 0x138)
    local damage = hp - newHP

    if (damage <= 0) then return end

    local damageAmp = 0.1
    if (isEffectActive("Berserk")) then
        -- print("Applying berserk damage amp.")
        damageAmp = 1.0
    end
    local modifiedDamage = damage * (1 + getActivityLevelSmoothed() * damageAmp)

    -- print(damage, modifiedDamage)

    RAX = hp - math.floor(modifiedDamage)
end
)
