-- [ EXTRA ATLAS ] extra-2x.png (1024x1024) with 256x256 cells.
-- singleLayer = true: only one layer per entry (the one with the correct offset for the top layer).

local D = EPF_CustomSkins_Definitions
if not D or not D.textureConfig then return end

local extraEntries = {
    -- Cell (0,0)
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Serpent",
        layout = {
            layers = {
                { width = 92, height = 92, leftTexCoord = 0/1024, rightTexCoord = 256/1024, topTexCoord = 0/1024, bottomTexCoord = 256/1024, pointOffset = { 8, 3 } },
            },
        },
    },
    -- Cell (1,0)
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Winged Moon",
        layout = {
            layers = {
                { width = 92, height = 92, leftTexCoord = 256/1024, rightTexCoord = 512/1024, topTexCoord = 0/1024, bottomTexCoord = 256/1024, pointOffset = { 8, -2 } },
            },
        },
    },
    -- Cell (2,0)
    --{ class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, goldTint = true, displayName = "Extra 3",
    --    layout = {
    --        layers = {
    --            { width = 128, height = 128, leftTexCoord = 512/1024, rightTexCoord = 768/1024, topTexCoord = 0/1024, bottomTexCoord = 256/1024, pointOffset = { 128, 0 } },
    --        },
    --    },
    --},
    -- Cell (3,0)
    --{ class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, goldTint = true, displayName = "Extra 4",
    --    layout = {
    --        layers = {
    --            { width = 128, height = 128, leftTexCoord = 768/1024, rightTexCoord = 1024/1024, topTexCoord = 0/1024, bottomTexCoord = 256/1024, pointOffset = { 128, 0 } },
    --        },
    --    },
    --},
    -- Cell (0,1)
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Dragon",
        layout = {
            layers = {
                { width = 106, height = 106, leftTexCoord = 0/1024, rightTexCoord = 256/1024, topTexCoord = 256/1024, bottomTexCoord = 512/1024, pointOffset = { 6, 6 } },
            },
        },
    },
    -- Cell (1,1)
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Valkyr",
        layout = {
            layers = {
                { width = 92, height = 92, leftTexCoord = 256/1024, rightTexCoord = 512/1024, topTexCoord = 256/1024, bottomTexCoord = 512/1024, pointOffset = { 6, -2 } },
            },
        },
    },
    -- Cell (2,1)
    --{ class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, goldTint = true, displayName = "Extra 7",
    --    layout = {
    --        layers = {
    --            { width = 128, height = 128, leftTexCoord = 512/1024, rightTexCoord = 768/1024, topTexCoord = 256/1024, bottomTexCoord = 512/1024, pointOffset = { 128, 0 } },
    --        },
    --    },
    --},
    -- Cell (3,1)
    --{ class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Extra 8",
    --    layout = {
    --        layers = {
    --            { width = 128, height = 128, leftTexCoord = 768/1024, rightTexCoord = 1024/1024, topTexCoord = 256/1024, bottomTexCoord = 512/1024, pointOffset = { 128, 0 } },
    --        },
    --    },
    --},
    -- Cell (0,2) — row 2
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Cataclysm Dragon",
        layout = {
            layers = {
                { width = 92, height = 92, leftTexCoord = 0/1024, rightTexCoord = 256/1024, topTexCoord = 512/1024, bottomTexCoord = 768/1024, pointOffset = { 8, 3 } },
            },
        },
    },
    -- Row 3 (bottom): 2 images, each 2 cells wide (512px)
    -- Left half (cells 0–1)
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Winged Moon Wide",
        layout = {
            layers = {
                { width = 160, height = 80, leftTexCoord = 0/1024, rightTexCoord = 512/1024, topTexCoord = 768/1024, bottomTexCoord = 1024/1024, pointOffset = { 20, -2 } },
            },
        },
    },
    -- Right half (cells 2–3)
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Valkyr Wide",
        layout = {
            layers = {
                { width = 160, height = 80, leftTexCoord = 512/1024, rightTexCoord = 1024/1024, topTexCoord = 768/1024, bottomTexCoord = 1024/1024, pointOffset = { 22, -2 } },
            },
        },
    },
}

for _, entry in ipairs(extraEntries) do
    D.textureConfig[#D.textureConfig + 1] = entry
end
