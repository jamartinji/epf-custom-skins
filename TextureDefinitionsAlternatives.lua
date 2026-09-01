-- [ ALTERNATIVE / MANUAL TEXTURES ] Spec alternatives, legacy skins, and CUSTOM entries.
-- Part of textureConfigFallback; load after RaceFaction; Extra atlas appends after this file.

EPF_CustomSkins_Definitions = EPF_CustomSkins_Definitions or {}
local D = EPF_CustomSkins_Definitions
D.textureConfigFallback = D.textureConfigFallback or {}

local entries = {
    { id = "dkcrimsonb", class = "DEATHKNIGHT", name = "dk_blood", layout = "bot", displayName = "Crimson Blade"},
    { id = "dklichking", class = "DEATHKNIGHT", name = "dk_frost", layout = "top", displayName = "The lich King"},
    { id = "dkplaguebr", class = "DEATHKNIGHT", name = "dk_unholy", layout = "bot", displayName = "Plaguebringer's Herald"},
    { id = "dkbloodbbb", class = "DEATHKNIGHT", name = "dk_blood-by-benjiro_blue", displayName = "Blood by Benjiro Blue",
        layout = {
            layers = {
                {
                    width = 280, height = 163,
                    leftTexCoord = 0/512, rightTexCoord = 512/512,
                    topTexCoord = 216/512, bottomTexCoord = 512/512,
                    pointOffset = { 190, -2 },
                },
            },
        },
    },
    { id = "dkfrostbbb", class = "DEATHKNIGHT", name = "dk_frost-by-benjiro_blue", displayName = "Frost by Benjiro Blue",
        layout = {
            layers = {
                {
                    width = 280, height = 163,
                    leftTexCoord = 0/512, rightTexCoord = 512/512,
                    topTexCoord = 216/512, bottomTexCoord = 512/512,
                    pointOffset = { 190, -12 },
                },
            },
        },
    },
    { id = "dhdevdevou", class = "DEMONHUNTER", name = "dh_devourer", displayName = "Devourer Horns", layout = "bot",  pointOffset = { 170, 0 } },
    { id = "dhillidari", class = "DEMONHUNTER", name = "dh_havoc", displayName = "Illidari Wrath", layout = "bot" },
    { id = "dhvengeful", class = "DEMONHUNTER", name = "dh_vengeance", layout = "bot", displayName = "Vengeful Torment" },
    { id = "druidnight", class = "DRUID", name = "druid_balance", displayName = "Night Owl", layout = "top" },
    { id = "druidfangs", class = "DRUID", name = "druid_feral", displayName = "Fangs of Ashamane", layout = "bot" },
    { id = "druidsavag", class = "DRUID", name = "druid_feral_savage", displayName = "Savage Feral Beast", layout = "top" },
    { id = "druidincar", class = "DRUID", name = "druid_feral_savage", displayName = "Incarnation of Nightmare", layout = "bot" },
    { id = "druidstone", class = "DRUID", name = "druid_guardian", displayName = "Stonepaw", layout = "bot" },
    { id = "druidwarde", class = "DRUID", name = "druid_restoration", displayName = "Warden's Crown", layout = "top" },
    { id = "druidalpha", class = "DRUID", name = "druid_guardian&restoration", displayName = "Alpha Claws", layout = "top" },
    { id = "druidgnarl", class = "DRUID", name = "druid_guardian&restoration", displayName = "Gnarled Roots", layout = "bot" },
    { id = "druidcrest", class = "DRUID", name = "druid", displayName = "Druid crest", layout = "bot" },
    { id = "evokerazure", class = "EVOKER", name = "evoker_azure", displayName = "Azure Guardian", layout = "top" },
    { id = "evokerbronz", class = "EVOKER", name = "evoker_bronze", displayName = "Keeper of Time", layout = "top", restIconOffset = { 150, 20 }},
    { id = "evokerysera", class = "EVOKER", name = "evoker_emerald", displayName = "The Dreamer", layout = "bot" },
    { id = "evokeralexs", class = "EVOKER", name = "evoker_ruby", displayName = "The Life-Binder", layout = "bot", restIconOffset = { 25, 0 } },
    { id = "evokerspell", class = "EVOKER", name = "evoker_azure", displayName = "The Spellweaver", layout = "bot" },
    { id = "evokernozdo", class = "EVOKER", name = "evoker_bronze", displayName = "The Timeless One", layout = "bot", restIconOffset = { 25, 0 } },
    { id = "evokernelth", class = "EVOKER", name = "evoker_obsidian", displayName = "The Worldbreaker", layout = "bot"},
    { id = "hunteeagle", class = "HUNTER", name = "hunter_mm_eagle", displayName = "Eagle Hunter", layout = "top"},
    { id = "hunteazure", class = "HUNTER", name = "hunter_mm_white", displayName = "Azure Thas'dorah", layout = "top" },
    { id = "hunteazure1", class = "HUNTER", name = "hunter_mm_white", displayName = "Azure Eagle", layout = "bot" },
    { id = "huntenelft", class = "HUNTER", name = "hunter_mm_banshee", displayName = "Nelf Thas'dorah", layout = "top" },
    { id = "huntebansh", class = "HUNTER", name = "hunter_mm_banshee", displayName = "Banshee Redemption", layout = "bot" },
    { id = "huntetalon", class = "HUNTER", name = "hunter_survival", displayName = "Talonclawer", layout = "top", pointOffset = { 178, 0 }, },
    { id = "monkzenle", class = "MONK", name = "monk", displayName="Zen Legacy", layout = "top", pointOffset = { 172, 10 }, },
    { id = "monkniuza", class = "MONK", name = "monk", displayName="Niuzao Spirit", layout = "bot", pointOffset = { 160, 0 }, },
    { id = "paladinbas", class = "PALADIN", name = "paladin_base&holy", ext = "png", layout = "top", pointOffset = { 170, 0 }, },
    { id = "paladjudge", class = "PALADIN", name = "paladin_protection", displayName="Judgement Charger", layout = "top", pointOffset = { 192, -8 }, restIconOffset = { 210, 0 }, },
    { id = "paladashbr", class = "PALADIN", name = "paladin_retribution", displayName="Ashbringer Judgement", layout = "bot" },
    { id = "prieslegac", class = "PRIEST", name = "priest", displayName = "Legacy priest", layout = "bot" },
    { id = "priestomek", class = "PRIEST", name = "priest_extras", displayName = "Tomekeeper's Spire", layout = "top" },
    { id = "priessacre", class = "PRIEST", name = "priest_extras", displayName = "Sacred disciple", layout = "bot" },
    { id = "priesdarkd", class = "PRIEST", name = "priest_shadow", displayName = "Dark devotion", layout = "bot" },
    { id = "priesxalat", class = "PRIEST", name = "priest_black_empire", displayName = "Xal'atath Blade", layout = "top" },
    { id = "priesblack", class = "PRIEST", name = "priest_black_empire", displayName = "Black Empire", layout = "bot" },
    { id = "roguekings", class = "ROGUE", name = "rogue_assassination", displayName = "Kingslayer", layout = "bot" },
    { id = "roguedread", class = "ROGUE", name = "rogue_outlaw", displayName = "Dreadblades", layout = "bot" },
    { id = "warloredhe", class = "WARLOCK", name = "warlock_demonhead", displayName = "Warlock (Old Red)", layout = "top" },
    { id = "warlopurhe", class = "WARLOCK", name = "warlock_demonhead", displayName = "Warlock (Old Purple)", layout = "bot" },
    { id = "felcofelco", class = "WARLOCK", name = "fel_corruption", displayName = "Fel corruption", layout = "dual" },
    { id = "destrinfer", class = "WARLOCK", name = "warlock_inferno", displayName = "Inferno Succubus", layout = "bot", pointOffset = { 172, 6 }, },
    { id = "destrintop", class = "WARLOCK", name = "warlock_inferno", displayName = "Infernal Ascendant", layout = "top", pointOffset = { 172, 6 }, },

    -- [ MANUAL-ONLY ] No class/race/spec; never auto-selected.
    { id = "corsapirat", class = "CUSTOM", name = "corsairs", displayName = "Pirate", layout = "top" },
    { id = "corsacorsa", class = "CUSTOM", name = "corsairs", displayName = "Corsair", layout = "bot" },
    { id = "voidshado", class = "CUSTOM", name = "void", displayName = "Void Shadow", layout = "bot", pointOffset = { 170, 0 }, },
    { id = "voidmatte", class = "CUSTOM", name = "void", displayName = "Void Matter", layout = "top", pointOffset = { 170, 0 }, },
    { id = "blackblack", class = "CUSTOM", name = "blackdragon", displayName = "Black Dragon", layout = "dual", },
}

for _, entry in ipairs(entries) do
    D.textureConfigFallback[#D.textureConfigFallback + 1] = entry
end