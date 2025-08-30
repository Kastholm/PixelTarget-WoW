# wowpixeladdon

Shows a bright **star marker** on your **current target’s nameplate** against a **pure black background**.  
This makes it trivial to detect via image recognition in external tools. Your program can then measure how far the star is from the **screen center** (your character) to infer aim/offset.

## What it does
- Renders a fixed-size star on targeted enemies.  
- Forces/paints a solid black rectangle behind the star (high contrast).  
- Keeps the star at consistent scale for reliable template matching.  
- Optional: toggles only in combat or while holding a hotkey.  

## Why it’s useful
- Simple CV pipeline: find star → compute center offset (dx, dy) → decide turn/move.  
- Works with low-resolution or compressed screenshots due to high contrast.  

## Typical CV flow (external tool)
1. Capture frame/screenshot.  
2. Crop to expected nameplate band (optional).  
3. Template or shape match the star.  
4. Get star centroid `(xs, ys)`.  
5. Compare to screen center `(xc, yc)` → `offset = (xs - xc, ys - yc)`.  
6. Use offset to steer/aim or verify lock-on. 
