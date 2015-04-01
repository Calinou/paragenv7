paragenv7 0.5.0 by paramat
For Minetest 0.4.12 stable and later
Depends default
Licenses: code WTFPL, textures CC BY-SA


Version changes:

Increase speed:
    2D perlinmap z-size = 1
    Noise objects created once instead of every chunk

Set nolight flag to calculate light once only after chunk generation
Clear the default mod's registered biomes and decorations
Check for and replace dirt, sand and gravel to remove ugly dirt and gravel blobs at surface
Use allfaces_optional drawtype for pine needles
