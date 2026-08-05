# RobloxBattleSystem
Luau script

It originated from my roblox game *Unnamed Battle Game*
https://www.roblox.com/games/131526004425694

Folder Names Correspond to Container Locations in Roblox

Just Place the Scripts Into Their Matching Folders

ReplicatedStorage:

- PlayerAttack (RemoteEvent)

Arm Structure Dependency:

Arm (Model) | Attribute: IsItem = true
- Attributes (Folder)
  - Size (Vector3Value)
  - Damage (NumberValue)
  - Interval (NumberValue)
  - DurationMultiplier (NumberValue) | For Example: 5

StartGui/MobileAttackButton Should be a ScreenGui

StartGui/MobileAttackButton/ButtonScript Should not be Enabled Initial
