local utils = require("utils")

----------------------------------------------------------------

local haloBaseAddress = resolvePointer("halo1.dll")

local pActiveWeapon = utils.allocateTemp(8, PAGE_READWRITE, haloBaseAddress)
onTick(function(dt)
    writeUint64(pActiveWeapon, getDefinition("activeWeapon"))
end)

----------------------------------------------------------------

-- No clip consumption:
--     Original code:
--         halo1.dll+B79159 - 66 45 89 4A 0A        - mov [r10+0A],r9w
utils.nop(resolvePointer("halo1.dll B79159"), 5)

----------------------------------------------------------------

-- Multi projectile hook:
--
--     Original code:
--         halo1.dll+B77F95: 41 0F B7 D4           - movzx edx,r12w
--         halo1.dll+B77F99: 8B CD                 - mov ecx,ebp
--         halo1.dll+B77F9B: E8 48 0E 00 00        - call halo1.dll+B78DE8
--         Notes:
--             rsi = weapon entity pointer

local hookAddress = resolvePointer("halo1.dll B77F9B")

local pProjMultiplier = utils.allocateTemp(8, PAGE_READWRITE, hookAddress)
onTick(function(dt)
    local multiplier = math.floor(getActivityLevelSmoothed() * 4)
    if (multiplier < 1) then
        multiplier = 1
    end
    writeUint64(pProjMultiplier, multiplier)
end)

utils.createJumpHook({
    address = hookAddress,
    nopCount = 5,
    symbols = {
        projectileFn = resolvePointer("halo1.dll B78DE8"),
        pProjMultiplier = pProjMultiplier,
        pActiveWeapon = pActiveWeapon
    },
    code = [[
        push rdi     ; rdi = repeatCounter
        sub rsp, 8   ; 16 byte alignment

            ; If not player weapon, use a multiplier of 1.
            cmp rsi, [pActiveWeapon]
            jne npcMultiplier
                mov rdi, qword ptr [pProjMultiplier]
                jmp multiplierEnd
            npcMultiplier:
                mov rdi, 1
            multiplierEnd:

            loopStart:
                push rdx
                push rcx
                    call projectileFn
                pop rcx
                pop rdx
            dec rdi
            jnz loopStart
        
        add rsp, 8   ; 16 byte alignment
        pop rdi
    ]]
})

----------------------------------------------------------------

-- Rate of fire hook:
--
--     Original code:
--         halo1.dll+B77CB1 - F3 0F10 41 08         - movss xmm0,[rcx+08]  ; Read max RoF.
--         halo1.dll+B77CB6 - F3 0F5C 41 04         - subss xmm0,[rcx+04]  ; Subtract min RoF.
--         halo1.dll+B77CBB - F3 0F59 C1            - mulss xmm0,xmm1      ; Multiply by interpolation factor.
--         halo1.dll+B77CBF - F3 0F58 41 04         - addss xmm0,[rcx+04]  ; Add min RoF.
--         Notes:
--             r9 = weapon entity pointer

-- Hook at end of RoF calculation.
local hookAddress = resolvePointer("halo1.dll B77CBF")

local pRofMultiplier = utils.allocateTemp(4, PAGE_READWRITE, hookAddress)
onTick(function(dt)
    local multiplier = getActivityLevelSmoothed() * 2
    if (multiplier < 0.1) then
        multiplier = 0.1
    end
    writeFloat(pRofMultiplier, multiplier)
end)


utils.createJumpHook({
    address = hookAddress,
    nopCount = 5,
    symbols = { 
        pRofMultiplier = pRofMultiplier,
        pActiveWeapon = pActiveWeapon
    },
    code = [[
        addss xmm0, [rcx + 0x04]   ; Add min RoF. (original code)

        ; If active weapon is not the player's weapon, skip the multiplier.
        cmp r9, [pActiveWeapon]
        jne skipRofMultiplier
            mulss xmm0, [pRofMultiplier]   ; Scale by activity level.
        skipRofMultiplier:
    ]]
})
