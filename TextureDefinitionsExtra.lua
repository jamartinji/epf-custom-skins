-- [ EXTRA ATLAS ] extra-2x.png (1024x1024) with 256x256 cells.
-- singleLayer = true: only one layer per entry (the one with the correct offset for the top layer).

local D = EPF_CustomSkins_Definitions
if not D or not D.textureConfig then return end

local extraEntries = {
    -- Cell (1,1) (1)
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Serpent",
        layout = {
            layers = {
                { width = 92, height = 92, leftTexCoord = 0/1024, rightTexCoord = 256/1024, topTexCoord = 0/1024, bottomTexCoord = 256/1024, pointOffset = { 8, 3 } },
            },
        },
    },
    -- Cell (1,2) (2)
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Winged Moon",
        layout = {
            layers = {
                { width = 92, height = 92, leftTexCoord = 256/1024, rightTexCoord = 512/1024, topTexCoord = 0/1024, bottomTexCoord = 256/1024, pointOffset = { 8, -2 } },
            },
        },
    },
     --Cell (1,3) (3)
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Gryphon",
        layout = {
            layers = {
                { width = 92, height = 92, leftTexCoord = 512/1024, rightTexCoord = 768/1024, topTexCoord = 0/1024, bottomTexCoord = 256/1024, pointOffset = { 10, 10 } },
            },
        },
    },
    -- Cell (1,4) (4)
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Wyvern",
        layout = {
            layers = {
                { width = 92, height = 92, leftTexCoord = 768/1024, rightTexCoord = 1024/1024, topTexCoord = 0/1024, bottomTexCoord = 256/1024, pointOffset = { 9, 11 } },
            },
        },
    },
    -- Cell (2,1) (5) — row 2
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Dragon",
        layout = {
            layers = {
                { width = 106, height = 106, leftTexCoord = 0/1024, rightTexCoord = 256/1024, topTexCoord = 256/1024, bottomTexCoord = 512/1024, pointOffset = { 6, 6 } },
            },
        },
    },
    -- Cell (2,2) (6)
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Valkyr",
        layout = {
            layers = {
                { width = 92, height = 92, leftTexCoord = 256/1024, rightTexCoord = 512/1024, topTexCoord = 256/1024, bottomTexCoord = 512/1024, pointOffset = { 6, -2 } },
            },
        },
    },
    -- Cell (2,3) (7)
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Gryphon 2",
        layout = {
            layers = {
                { width = 92, height = 92, leftTexCoord = 512/1024, rightTexCoord = 768/1024, topTexCoord = 256/1024, bottomTexCoord = 512/1024, pointOffset = { 10, 10 } },
            },
        },
    },
    -- Cell (2,4) (8)
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Wyvern 2",
        layout = {
            layers = {
                { width = 92, height = 92, leftTexCoord = 768/1024, rightTexCoord = 1024/1024, topTexCoord = 256/1024, bottomTexCoord = 512/1024, pointOffset = { 10, 11 } },
            },
        },
    },
    -- Cell (3,1) (9) — row 3
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Cataclysm Dragon",
        layout = {
            layers = {
                { width = 92, height = 92, leftTexCoord = 0/1024, rightTexCoord = 256/1024, topTexCoord = 512/1024, bottomTexCoord = 768/1024, pointOffset = { 8, 5 } },
            },
        },
    },
    -- Cell (3,2) (10)
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Dual Wings",
        layout = {
            layers = {
                { width = 142, height = 142, leftTexCoord = 256/1024, rightTexCoord = 512/1024, topTexCoord = 512/1024, bottomTexCoord = 768/1024, pointOffset = { 36, 0 } },
            },
        },
    },
    -- Cell (3,3) (11)
    --{ class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "TBD",
    --    layout = {
    --        layers = {
    --            { width = 92, height = 92, leftTexCoord = 0/1024, rightTexCoord = 256/1024, topTexCoord = 512/1024, bottomTexCoord = 768/1024, pointOffset = { 8, 3 } },
    --        },
    --    },
    --},
    -- Cell (3,4) (12)
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Manticore",
        layout = {
            layers = {
                { width = 100, height = 100, leftTexCoord = 768/1024, rightTexCoord = 1024/1024, topTexCoord = 512/1024, bottomTexCoord = 768/1024, pointOffset = { 16, 12 } },
            },
        },
    },
    -- Row 4 (bottom): 2 images, each 2 cells wide (512px)
    -- Left half (cells 1–2)
    { class = "CUSTOM", name = "extra", ext = "png", singleLayer = true, displayName = "Winged Moon Wide",
        layout = {
            layers = {
                { width = 160, height = 80, leftTexCoord = 0/1024, rightTexCoord = 512/1024, topTexCoord = 768/1024, bottomTexCoord = 1024/1024, pointOffset = { 20, -2 } },
            },
        },
    },
    -- Right half (cells 3–4)
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
