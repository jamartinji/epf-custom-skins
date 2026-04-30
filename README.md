# EPF Custom Skins

[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-blue.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)
[![Version](https://img.shields.io/badge/Version-1.2.5-informational)](ElitePlayerFrame_Enhanced_CustomSkins.toc)
[![WoW](https://img.shields.io/badge/WoW-12.0%20(TWW)-orange)](https://worldofwarcraft.blizzard.com/)
[![Lua](https://img.shields.io/badge/Lua-5.x-blue)](https://www.lua.org/)

Add-on that **extends [Elite Player Frame (Enhanced)](https://www.curseforge.com/wow/addons/elite-player-frame-enhanced)** with custom frame textures and extra selection options.

---

## ✨ What This Add-on Adds (vs. Original)

| Feature | Original EPF Enhanced | This add-on |
| --- | --- | --- |
| Auto selectors (class/spec/race/sex/faction) | Yes | Uses the same EPF selectors; adds more custom skins that can participate in Auto |
| Texture framework / custom mode API | Yes | Uses EPF API and ships a curated set of custom textures and rules |
| Included per-spec skins | Limited to what EPF ships | Expanded predefined set (for example multiple Warlock specs, Devourer) |
| Included fallback rules (class/race/faction) | Limited to what EPF ships | Expanded predefined fallback entries and alternatives |
| Options UX for EPF settings | Slash commands + addon compartment controls | Dedicated options panel that controls EPF settings in one place |
| Manual texture picking | Yes (`/epf frame`) | Yes (same EPF mode list, with custom entries registered by this addon) |

---

## 📌 Requirements

- **ElitePlayerFrame_Enhanced** must be installed and enabled.
- Recommended EPF version: **1.10.4+**.

## 📥 Installation

1. Install **Elite Player Frame (Enhanced)** first.
2. Download or clone this addon and place the **ElitePlayerFrame_Enhanced_CustomSkins** folder inside your WoW `_classic_era_` or `_retail_` **Interface\AddOns** directory.
3. Enable both addons in the character selection screen (AddOns button) or in-game (Esc → System → AddOns).

---

## ⚙️ Options Panel

The addon adds a configuration panel under **Esc → System → AddOns → EPF Custom Skins** (or **Interface → AddOns** depending on client). From there you can:

- **Display** — Show or hide the player frame modifications (EPF `display` setting).
- **Class selection** — Toggle EPF class-based selection in Auto mode.
- **Sex selection** — Toggle EPF sex-based selection in Auto mode.
- **Faction selection** — Toggle EPF faction-based selection in Auto mode.
- **Display in instances** — Toggle EPF `instances` behavior.
- **Message output level** — Verbosity of addon messages (0 = critical only, higher = more debug).
- **Reset** — Calls EPF reset and refreshes synced settings.
- **Available textures** — Scrollable list of all EPF frame modes (built-in + registered custom textures). Use **Filter** to search and click a row to select (`/epf frame N` equivalent).

---

## 🎨 How to Add Textures

1. Put texture files (e.g. PNG) in the add-on’s **`assets/`** folder.
2. Add **`-2x`** versions (e.g. `warlock-2x.png`) for high-DPI.
3. Edit texture definition tables:
   - **`TextureDefinitions.lua`** → specialization-first entries in `textureConfigSpec`.
   - **`TextureDefinitionsFallback.lua`** → class defaults, race/faction fallbacks, and manual alternatives in `textureConfigFallback`.
   - **`TextureDefinitionsExtra.lua`** → appends extra manual entries into fallback definitions.

Each entry has:
   - **class** (required): e.g. `"WARLOCK"`, `"DRUID"`.
   - **name** and **ext**: file name and extension (e.g. `"warlock"`, `"png"`).
   - **spec** (optional): specialization ID for spec-only skins.
   - **race** (optional): race API string (e.g. `"Human"`, `"Scourge"`, `"Dracthyr"`).
   - **faction** (optional): `"Alliance"` or `"Horde"`. Only applied when `/epf faction` is on.
   - **displayName** (optional): menu label (e.g. for manual-only textures).
   - **layout** (optional): custom frame layout for this entry; see below. If omitted, `defaultFrameLayout` is used.

### Frame layout

In **`TextureDefinitions.lua`**, **`defaultFrameLayout`** defines sizes, texture coordinates (UV), and positions for each texture layer and for the rest icon. All entries in `textureConfigSpec` and `textureConfigFallback` use it unless they set their own **`layout`**.

- **`defaultFrameLayout`** has:
  - **`layers`**: array of layer tables. Each layer has **`width`**, **`height`**, **`leftTexCoord`**, **`rightTexCoord`**, **`topTexCoord`**, **`bottomTexCoord`**, and **`pointOffset`** = `{ x, y }`.
  - **`restIconOffset`**: `{ x, y }` for the rest icon position.

To use different dimensions or positions for a specific texture, add a **`layout`** to that entry with the same structure (e.g. different `width`/`height` or `pointOffset` per layer). Example: a texture that uses a 1024×512 atlas with different crop and offsets would set `layout = { layers = { ... }, restIconOffset = { -3, 13 } }` on that entry.

### Load order and priority

Auto selection uses an ordered priority flow:

- Specialization-specific custom entries (`textureConfigSpec`) are evaluated first.
- Base EPF class defaults are evaluated next.
- Fallback custom entries (`textureConfigFallback`) are evaluated after base class defaults.
- Classless fallback entries (race/faction) are last, so they do not override class defaults.

---

## ⌨️ Choosing Textures with /epf

The base addon provides several slash commands. Use **`/epf help`** to list them.

### Auto selection toggles

- **`/epf class`** — toggles **class-based** frame selection in automatic mode. **Enabled by default.** When on, the addon (and this add-on’s textures) picks the skin by your class (and, with this add-on, by spec/race). When off, automatic mode ignores class.
- **`/epf spec`** — toggles specialization-based selection in automatic mode.
- **`/epf race`** — toggles race-based selection in automatic mode.
- **`/epf sex`** — toggles sex-based selection in automatic mode.
- **`/epf faction`** — toggles **faction-based** frame selection in automatic mode. **Enabled by default.** When on, entries in `textureConfig` that have **faction** set (e.g. `faction = "Horde"`) will only match that faction.

For automatic behavior, use **`/epf frame 1`** and leave the selector toggles you want enabled.

### Frame mode (picking a texture)

The base addon lists **all frame modes** (built-in + the ones this add-on registers) and assigns each a **number**:

- **`/epf frame`** — shows the current mode and, with **`/epf frame help`**, the full list with numbers.
- **`/epf frame 0`** — no custom texture (disabled).
- **`/epf frame 1`** — **automatic** mode: the addon picks the texture (by class/spec/race when class selection is on; this add-on updates it when you change spec).
- **`/epf frame 2`**, **`/epf frame 3`**, … — use the texture at that position in the list (fixed until you change it or switch back to 1).

So for automatic behaviour: **`/epf frame 1`** and leave **`/epf class`** on. To force a single skin: **`/epf frame help`** to see numbers, then **`/epf frame <number>`**.

---

## 🤝 Contributing

You are welcome to:

- **Propose a pull request (PR)** to add new skins or improve this addon.
- **Fork this addon** to maintain your own set of textures; you may use this project as a base and publish your fork under the same or a compatible license (see [LICENSE](LICENSE.md)).

There is no “user folder” for custom textures; to add textures, please submit a PR or use a fork.

---

## 👤 Author

**Drakeinhart**

---

## 📄 License

This addon is licensed under [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)](LICENSE.md). You may share and adapt with attribution; **commercial use is not permitted**, and derivatives must use the same license. See [LICENSE.md](LICENSE.md) for the full text.

---

## 🚀 Publishing to CurseForge

A GitHub Actions workflow can build a zip and upload it to CurseForge when you **publish a release** or run it **manually**. Configure the required secrets (API token, project ID, game version IDs) and steps in [.github/CURSEFORGE-SETUP.md](.github/CURSEFORGE-SETUP.md).
