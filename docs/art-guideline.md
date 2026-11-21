# Idle Stories — art guideline

This is the agreed look of the game: **low-poly flat 3D**, one busy room seen from above. Every asset and every screen follows this file. The scene art is built by `tool/render_assets.py`; the interface is drawn in `lib/ui.dart`.

## 1. Pillars

1. **Crisp.** Flat colours and hard edges. Nothing soft, glossy or blurred.
2. **Busy, not messy.** A zone is a small story with people, furniture and props, and it reads at thumbnail size.
3. **Indian in the details.** The setting is carried by props (chai, tiffin, carrom, marigold toran, rangoli rug, cricket bat), not by clichés or flags.
4. **One style everywhere.** Scene, icons and interface share one palette and one set of rules.

## 2. Shape language

- Everything is built from boxes, low-sided cylinders (5 to 8 sides) and low-detail spheres.
- There are no bevels, no smooth shading and no textures. A detail is a separate coloured block.
- Silhouettes are chunky. If a part is thinner than a person's arm, thicken it or remove it.
- Each zone has one large hero prop that names it: a server rack, a whiteboard, a giant phone, a glowing AI core, a founder's desk.

## 3. Proportions

- People are about 2.5 heads tall with a large head, a block body, short legs and no fingers.
- Faces are two dark eyes only. Hair sits on top and behind the head and never covers the face.
- Furniture is scaled to the people, and props are oversized by about 20% so they stay readable.

## 4. Palette

| Role | Colour |
| --- | --- |
| Floor | `#F3E2C2`, `#E9D2A8` |
| Wall, wall band, trim | `#FBF6EC`, `#2EC4B6`, `#1E9E93` |
| Wood | `#D9954F`, `#B26F2E` |
| Dark neutral | `#2B3550`, `#44517A` |
| Accents | saffron `#FF8A3D`, marigold `#FFB020`, pink `#FF4F8B`, indigo `#6C63FF`, teal `#2EC4B6` |
| Plants | `#3FBF6B`, `#2E9E57`, pot `#E4572E` |
| Metal and glass | `#C9D3DF`, `#8E9BB0`, sky `#9EDCF5` |
| Interface | ink `#22304A`, soft ink `#7A8699`, surface `#F1F5F9`, lip `#C9D3DF`, backdrop mint `#8FD9C8` |
| Buttons (face, lip) | green `#34C768` `#1F8F4E`; amber `#FFB020` `#D98700`; blue `#3D7BFF` `#2757C9`; disabled `#B8C2D0` `#8E9BB0` |

Use warm neutrals for large areas and keep the accents for things the player should notice. A zone uses at most three accents. New colours are added to this table before they are used.

## 5. Materials

- Matte diffuse colour only. No gloss, metal or glass shaders.
- Screens, lamps and the AI core glow with a flat emission colour.

## 6. Camera and light

- Orthographic camera, rotated 60° down and 45° around, the same for every scene render.
- One hard sun from the upper left gives each object a light face, a mid face and a dark face, with a short sharp shadow.
- A pale sky fill keeps shadows coloured, never black.
- All office layers are rendered from the same camera at the same size so they stack exactly.

## 7. Environment

- The office is one room with two back walls. Zones are added to it as products are launched, so the room fills up as the player grows.
- Each zone is a separate layer. A new zone must not hide the hero prop of a zone behind it.
- The front of the room holds a lounge that is always visible, so an early office never looks empty.

## 8. Interface

- The font is Anek Devanagari at width 105. Its sister Anek families are used for other Indian scripts. Titles use weight 800, body text 700 and notes 500.
- Panels are white with a 20 px corner radius and a solid lip beneath. There are no blurred shadows and no gradients on controls.
- Buttons are a flat face on a darker lip and sink onto the lip when pressed. Green means spend or continue, amber means unlock, blue means hire, grey means unavailable.
- Money is always shown with the coin and the ₹ sign. Income is green.
- The scene sits at the top of the screen and controls sit in a white sheet below it.

## 9. Do and do not

| Do | Do not |
| --- | --- |
| Flat faces with three clear tones | Gradients, gloss, soft shadows |
| A few large readable props | Many tiny props that blur at phone size |
| People in every zone | Empty furniture showrooms |
| Colours from the table | Near-miss shades picked by eye |
| Icons cropped from the same scene | Icons drawn in another style |
| Original characters and props | Anything recognisable from another game |

## 10. Checklist for a new asset

1. It is built only from the shapes in section 2.
2. Every colour comes from section 4.
3. It is rendered with the shared camera and light.
4. It reads clearly at 64 px.
5. It has been viewed on the simulator next to existing assets.
