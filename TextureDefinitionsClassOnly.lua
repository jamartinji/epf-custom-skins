-- [ CLASS-ONLY FALLBACK TEXTURES ] Generic class defaults when no spec entry matches.
-- Part of textureConfigFallback; load order: ClassOnly -> RaceFaction -> Alternatives -> Extra.

EPF_CustomSkins_Definitions = EPF_CustomSkins_Definitions or {}
local D = EPF_CustomSkins_Definitions
D.textureConfigFallback = D.textureConfigFallback or {}

local entries = {
    -- { class = "DEATHKNIGHT", name = "deathknight", ext = "png" },
    -- { class = "DEMONHUNTER", name = "demonhunter", ext = "png" },
    { class = "DRUID", name = "druid", ext = "png",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },
    { class = "EVOKER", name = "evoker", ext = "png" },
    { class = "HUNTER", name = "hunter_base&bm", ext = "png",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0 / 512, bottomTexCoord = 256/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },
    { class = "MAGE", name = "mage", ext = "png",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 256 / 512, bottomTexCoord = 512/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },
    { class = "MONK", name = "monk_base&brew", ext = "png", displayName="Celestials",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 172, 10 },
                },
            },
        },
    },
    { class = "PRIEST", name = "priest", ext = "png",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },
    { class = "ROGUE", name = "rogue_base&subtley", ext = "png",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },
    { class = "SHAMAN", name = "shaman_base&resto", ext = "png",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },
    { class = "WARLOCK", name = "warlock", ext = "png",
        layout = {
            layers = {
                { pointOffset = { 38, -4 } },
                { pointOffset = { 168, -4 } },
            },
        },
    },
    { class = "WARRIOR", name = "warrior_base&protection", ext = "png",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },
}

for _, entry in ipairs(entries) do
    D.textureConfigFallback[#D.textureConfigFallback + 1] = entry
end
