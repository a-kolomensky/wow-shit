function(allstates, event, ...)

    -- local predvidenieSpellId = 409311
    -- local predvidenieBuffId = 410089
    -- local ebonMightBuffId = 395152

    local predvidenieSpellId = 139
    local predvidenieBuffId = 139
    local ebonMightBuffId = 395152

    local burstBuffsToCheck = {
        [17] = true, -- Shield
        -- DK
        [42650] = true,    -- Army of the Dead
        [49206] = true,    -- Summon Gargoyle
        [47568] = true,    -- Empower Rune Weapon
        [51271] = true,    -- Pillar of Frost
        [152279] = true,   -- Breath of Sindragosa

        -- DH
        [191427] = true,   -- Metamorphosis
        [162264] = true,   -- Metamorphosis

        -- Druid
        [194223] = true,   -- Celestial Alignment
        [102560] = true,   -- Incarnation: Chosen of Elune
        [102543] = true,   -- Incarnation: King of the Jungle

        -- Mage
        [365350] = true,   -- Arcane Surge
        [321507] = true,   -- Touch of the Magi
        [12472] = true,    -- Icy Veins
        [190319] = true,   -- Combustion

        -- Monk
        [123904] = true,   -- Invoke Xuen, the White Tiger

        -- Priest
        [10060] = true,    -- Power Infusion
        [391109] = true,   -- Dark Ascension
        [34433] = true,    -- Shadowfiend
        [200174] = true,   -- Mindbender
        [194249] = true,   -- Voidform

        -- Rogue
        [360194] = true,   -- Deathmark
        [13750] = true,    -- Adrenaline Rush
        [121471] = true,   -- Shadow Blades

        -- Shaman
        [198067] = true,   -- Fire Elemental
        [384352] = true,   -- Doom Winds
        [375982] = true,   -- Primordial Wave
        [114050] = true,   -- Ascendance (Elemental)
        [114051] = true,   -- Ascendance (Enhancement)
        [192249] = true,   -- Storm Elemental

        -- Warlock
        [267217] = true,   -- Nether Portal
        [386997] = true,   -- Soul Rot
        [205180] = true,   -- Summon Darkglare
        [265187] = true,   -- Summon Demonic Tyrant
        [1122] = true,     -- Summon Infernal

        -- Warrior
        [1719] = true,     -- Recklessness
        [107574] = true,   -- Avatar
        [167105] = true,   -- Colossus Smash

        -- Paladin
        [31884] = true,    -- Avenging Wrath
        [231895] = true,   -- Crusade

        -- Hunter
        [19574] = true,    -- Bestial Wrath
        [288613] = true,   -- Trueshot
        [360952] = true,   -- Coordinated Assault

        -- Evoker
        [375087] = true    -- Dragonrage
    }

    -- Просто проверка что мы будем работать по нашим живым тиммейтам (не изменять)
    local unitList = {}

    local unitType = IsInRaid() and "raid" or "party"
    local numGroupMembers = GetNumGroupMembers()

    local i = 1
    for unit in WA_IterateGroupMembers() do

        local isBuffedPredvidenie = 0
        local isBuffedEbonMight = 0
        local isActiveBurst = 0

        local groupIndex = "player"
        for j = 1, numGroupMembers do
            if UnitGUID(unitType..j) == UnitGUID(unit) then
                groupIndex = "raid" .. j
                break
            end
        end

        for i = 1, 40 do
            local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId = UnitBuff(unit, i)
            if spellId then
                spellId = tonumber(spellId)  -- Приведение к числу

                if spellId == predvidenieBuffId then
                    isBuffedPredvidenie = isBuffedPredvidenie + 1
                end

                if spellId == ebonMightBuffId then
                    isBuffedEbonMight = isBuffedEbonMight + 1
                end

                if burstBuffsToCheck[spellId] then
                    isActiveBurst = 1
                end

            end
        end

        if not (isBuffedPredvidenie == 2)
        and (not UnitIsDeadOrGhost(unit))
        -- and unit in raid or party
        and (UnitIsConnected(unit))
        and WeakAuras.IsSpellInRange(predvidenieSpellId, unit) == 1 then
            unitList[i] = {
                id = groupIndex,
                guid = UnitGUID(unit),
                friend = 0,
                myPrescience = {
                    applied = isBuffedPredvidenie,
                },
                myEbonMight = {
                    applied = isBuffedEbonMight,
                },
                burst = {
                    applied = isActiveBurst,
                },
                nickname = GetUnitName(unit)
            }
            i = i + 1
        end
    end












    -- Сортировка (доработаем логику на кого первого навешивать)
    if unitList[1] then
        local function customSortCombat(a,b)
            if a.myPrescience.applied ~= b.myPrescience.applied then
                return a.myPrescience.applied
            end

            if a.burst.applied ~= b.burst.applied then
                return a.burst.applied
            end

            if a.myEbonMight.applied ~= b.myEbonMight.applied then
                return a.myEbonMight.applied
            end

            return a.friend < b.friend
        end

        table.sort(unitList, customSortCombat)
    end













    -- just return first element (не изменять)


    for n, player in ipairs(unitList) do
        print(player.id)
        return;
        -- return guid -- replace to party1 etc...
    end

    return 0


end