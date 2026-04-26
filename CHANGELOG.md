# Changelog

All notable changes to **EPF Custom Skins** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.5] - 2026-04-26

### Changed

- Split main texture definitions into specialization-first (`TextureDefinitions.lua`) and fallback (`TextureDefinitionsFallback.lua`) groups to keep ordering maintainable.
- Updated extra atlas injections (`TextureDefinitionsExtra.lua`) to append into fallback definitions after the split.
- Updated options integration to use `ElitePlayerFrame_Enhanced:Reset()` and EPF callbacks for settings synchronization on modern EPF versions.

### Fixed

- Corrected custom mode ordering so base EPF class defaults (notably Death Knight and Demon Hunter) are evaluated before classless race/faction fallbacks.
- Added delayed reorder passes to handle EPF callback timing where base custom modes may be appended after initial registration.
- Restored localized race/faction menu labels and dynamic faction color styling in the texture list.
- Removed unnecessary custom-mode re-registration on `SETTINGS_RESET` (fixed upstream in EPF 1.10.3).

## [1.2.4] - 2026-04-25

### Changed

- Simplified `Core.lua` to target `ElitePlayerFrame_Enhanced` `>= 1.10.1` only, removing legacy compatibility paths, delayed retries, and multi-stage registration flow.
- Registration now uses `ElitePlayerFrame_Enhanced:WhenInitialised()` as the single entrypoint and uses EPF selection helpers directly for auto-condition checks.

### Fixed

- Kept class/spec custom mode prioritization so the Devourer (`spec = 1480`) skin resolves before base EPF Demon Hunter class mode.

## [1.2.3] - 2026-04-25

### Fixed

- Updated the instances option wording to match EPF semantics: the toggle now reads as display/enabled in instances instead of hide.
- Updated localization strings for the instances option label and description across all locale files.

## [1.2.2] - 2026-04-25

### Added

- Added Demon Hunter Devourer skin support using `spec = 1480`  the `void`.
- Added a `Void Shadow` alternative custom entry.

### Fixed

- Fixed Auto mode priority so `ElitePlayerFrame_Enhanced` base Demon Hunter skin won't override the Devourer-specific custom skin.
- Refined custom frame mode reordering to prioritize class/spec custom entries only, preventing faction-only entries from being selected prematurely.

## [1.2.1] - 2026-04-25

### Added

- Void Themed Frames

## [1.2.1] - 2026-04-25

### Added

- Added explicit minimum dependency requirement: `ElitePlayerFrame_Enhanced` **v1.10.1 or newer**.

### Fixed

- Improved startup registration resilience for custom frame modes on slower clients/load orders.

## [1.2.0] - 2026-04-20

### Changed

- Updated compatibility for recent `ElitePlayerFrame_Enhanced` API changes.
- Delegated **Hide in instance** behavior fully to EPF base (`instances` setting), keeping this addon as UI-only for that option.

### Added
- Added **Sex selection** toggle to the options panel (delegated to EPF base setting).

## [1.1.7] - 2026-04-19

- Bump version for 12.0.5.

## [1.1.6]

### Added

- Mage specialization frames.
- Warrior frame.

## [1.1.5]

### Added

- Mage frame.

## [1.1.4]

### Added

- Priest frames.

## [1.1.3]

### Added

- Paladin frame.
- Base warlock frame.

## [1.1.2]

### Added

- Alliance faction entry.
- Additional extra custom textures.

## [1.1.1]

### Fixed

- Uploaded missing file.

## [1.1.0]

### Added

- Extra atlas support via `TextureDefinitionsExtra.lua` (`extra-2x.png`, 1024x1024 with 256x256 cells).
- `singleLayer` option so a texture can use only one layer (`Portrait`) with its own layout.
- Horde faction entry and `singleLayer` documentation in `TextureDefinitions.lua`.
- Extra atlas skins: Serpent, Winged Moon, Dragon, Valkyr, Cataclysm Dragon, Winged Moon Wide, Valkyr Wide.

## [1.0.11]

### Fixed

- Korean addon category text.

### Changed

- Optimized texture files to reduce image size.

### Added

- Assassination Rogue, base Rogue, and base Druid textures.

## [1.0.10]

### Fixed

- Texture filename.

## [1.0.9]

### Changed

- Options panel switched to a two-column layout and text simplified to fit.
- Updated destruction warlock design (infernal added).
- Added alternative destruction warlock design (succubus variant).

## [1.0.8]

### Added

- New option: **Hide in instance**.
- Pandaren and monk textures.

### Fixed

- Default texture class assignments.

## [1.0.7]

### Fixed

- Affliction texture offset.

### Added

- Scourge frame.

## [1.0.6]

### Changed

- Layout overrides now require only changed fields (for example `pointOffset`) instead of full layout declarations.
- Removed `(Custom)` suffix from default class textures.

### Added

- Revamped warlock affliction and destruction textures.
- Base shaman texture.

## [1.0.5]

### Added

- New configuration panel with integrated EPF settings:
  - Display
  - Class selection
  - Faction selection
  - Output level dropdown
  - Reset button
- Base hunter texture.

## [1.0.4]

### Fixed

- Interface version in `.toc`.

## [1.0.3]

### Changed

- Addon folder and references renamed from `Enhacned` to `Enhanced` (correct spelling).
- `.toc` renamed to `ElitePlayerFrame_Enhanced_CustomSkins.toc`.

## [1.0.2]

### Fixed

- `Notes-esES` typo in `.toc`.
- BlackDragon texture issue.

### Added

- `displayName` for generic warlock skin.
- Updated warlock demonology and default textures.

## [1.0.1]

### Changed

- Split addon into `TextureDefinitions.lua` (data) and `Core.lua` (logic).
- Added configurable `defaultFrameLayout` and optional per-entry `layout`.
- README updated with layout and contribution documentation.
- GitHub Action to create version tags from `.toc`.

### Fixed

- Restoration druid texture.

## [1.0.0]

### Added

- Initial release.
- Custom frame textures for Elite Player Frame (Enhanced).
- Selection by class, specialization, race, and faction.
- Auto-update on specialization change.
