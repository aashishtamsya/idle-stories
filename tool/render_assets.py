# Renders the game art with Blender, following docs/art-guideline.md:
# flat-shaded low-poly, no bevels, no textures, one fixed camera and light.
#
# Run:  blender -b -P tool/render_assets.py -- "$PWD/assets/art" [preview.png]
#
# Output: office_<layer>.png (full-frame layers that stack into one office),
# icon_<zone>.png (one per product), manager.png. The optional second
# argument renders the whole office in one image for a quick look.
import math
import sys

import bmesh
import bpy
from mathutils import Matrix, Vector

ARGS = sys.argv[sys.argv.index("--") + 1:]
OUT = ARGS[0]
PREVIEW = ARGS[1] if len(ARGS) > 1 else None

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.samples = 64
scene.cycles.max_bounces = 3
try:
    scene.cycles.use_denoising = True
except Exception:
    pass
scene.render.film_transparent = True
scene.render.image_settings.file_format = "PNG"
scene.render.image_settings.color_mode = "RGBA"
scene.view_settings.view_transform = "Standard"

world = bpy.data.worlds.new("w")
scene.world = world
world.use_nodes = True
bg = world.node_tree.nodes.get("Background")
bg.inputs[0].default_value = (0.9, 0.93, 1.0, 1)
bg.inputs[1].default_value = 0.85

cam_data = bpy.data.cameras.new("cam")
cam_data.type = "ORTHO"
cam = bpy.data.objects.new("cam", cam_data)
scene.collection.objects.link(cam)
scene.camera = cam
cam.rotation_euler = (math.radians(60), 0, math.radians(45))
VIEW = Vector((-0.612, 0.612, -0.5))  # direction the camera looks along

# One hard sun: top faces brightest, left faces mid, right faces darkest.
sun_data = bpy.data.lights.new("sun", "SUN")
sun_data.energy = 2.5
sun_data.angle = math.radians(2)
sun = bpy.data.objects.new("sun", sun_data)
scene.collection.objects.link(sun)
sun.rotation_euler = (math.radians(40), 0, math.radians(25))


def hexc(h):
    h = h.lstrip("#")
    return tuple((int(h[i:i + 2], 16) / 255) ** 2.2 for i in (0, 2, 4)) + (1,)


_mats = {}


def mat(color, emit):
    key = (color, emit)
    if key not in _mats:
        m = bpy.data.materials.new("m")
        m.use_nodes = True
        nt = m.node_tree
        nt.nodes.clear()
        out = nt.nodes.new("ShaderNodeOutputMaterial")
        sh = nt.nodes.new("ShaderNodeEmission" if emit else "ShaderNodeBsdfDiffuse")
        sh.inputs[0].default_value = hexc(color)
        nt.links.new(sh.outputs[0], out.inputs[0])
        _mats[key] = m
    return _mats[key]


LAYER = "base"
_group = None


def _add(bm, loc, color, emit, rot=(0, 0, 0)):
    me = bpy.data.meshes.new("o")
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new("o", me)
    scene.collection.objects.link(o)
    o.location = loc
    o.rotation_euler = rot
    me.materials.append(mat(color, emit))
    o["layer"] = LAYER
    if _group is not None:
        _group.append(o)
    return o


def B(x, y, z, w, d, h, color, emit=False, rz=0.0):
    """Box from its minimum corner."""
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= w
        v.co.y *= d
        v.co.z *= h
    return _add(bm, (x + w / 2, y + d / 2, z + h / 2), color, emit,
                (0, 0, math.radians(rz)))


def C(cx, cy, z, r, h, color, seg=8, r2=None, emit=False, rot=None):
    """Faceted cylinder standing on z (or centred on z when rotated)."""
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=seg, radius1=r,
                          radius2=r if r2 is None else r2, depth=h)
    if rot:
        return _add(bm, (cx, cy, z), color, emit, tuple(math.radians(a) for a in rot))
    return _add(bm, (cx, cy, z + h / 2), color, emit)


def I(cx, cy, cz, r, color, sub=1, scale=(1, 1, 1), emit=False):
    """Faceted ball."""
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=sub, radius=r)
    for v in bm.verts:
        v.co.x *= scale[0]
        v.co.y *= scale[1]
        v.co.z *= scale[2]
    return _add(bm, (cx, cy, cz), color, emit)


def place(fn, x, y, deg=0.0, s=1.0, **kw):
    """Builds fn around the origin, then turns, scales and moves it."""
    global _group
    _group = []
    fn(**kw)
    m = (Matrix.Translation((x, y, 0)) @ Matrix.Rotation(math.radians(deg), 4, "Z")
         @ Matrix.Scale(s, 4))
    for o in _group:
        o.matrix_basis = m @ o.matrix_basis
    _group = None


# ---- Palette (see docs/art-guideline.md) ----
FLOOR_A, FLOOR_B, SLAB = "#F3E2C2", "#E9D2A8", "#B98F5E"
WALL, WALL_BAND, TRIM = "#FBF6EC", "#2EC4B6", "#1E9E93"
WOOD, WOOD_D = "#D9954F", "#B26F2E"
NAVY, NAVY_L = "#2B3550", "#44517A"
SAFFRON, MARIGOLD, PINK = "#FF8A3D", "#FFB020", "#FF4F8B"
INDIGO, TEAL, GREEN, RED = "#6C63FF", "#2EC4B6", "#34C768", "#E5484D"
LEAF, LEAF_D, POT = "#3FBF6B", "#2E9E57", "#E4572E"
SKY, WHITE, GREY, STEEL = "#9EDCF5", "#FFFFFF", "#C9D3DF", "#8E9BB0"
SKIN = ["#E2A77A", "#C68652", "#A86B3C"]
HAIR = "#2B1A12"


# ---- Reusable pieces. People and desks face +y. ----
def person(ox=0, oy=0, shirt=SAFFRON, skin=SKIN[0], hair=HAIR, pants=NAVY,
           seated=False, bun=False):
    if seated:
        tz = 0.5
        for dx in (-0.22, 0.04):
            B(ox + dx, oy - 0.05, 0.42, 0.18, 0.42, 0.16, pants)
            B(ox + dx, oy + 0.25, 0.04, 0.18, 0.14, 0.4, pants)
            B(ox + dx, oy + 0.25, 0, 0.18, 0.24, 0.07, WHITE)
    else:
        tz = 0.45
        for dx in (-0.2, 0.03):
            B(ox + dx, oy - 0.09, 0.06, 0.17, 0.18, 0.4, pants)
            B(ox + dx, oy - 0.09, 0, 0.17, 0.26, 0.07, WHITE)
    B(ox - 0.25, oy - 0.15, tz, 0.5, 0.3, 0.5, shirt)
    for dx in (-0.38, 0.25):
        B(ox + dx, oy - 0.1, tz + 0.14, 0.13, 0.2, 0.34, shirt)
        if seated:
            B(ox + dx, oy + 0.02, tz + 0.12, 0.12, 0.36, 0.11, skin)
        else:
            B(ox + dx + 0.01, oy - 0.07, tz + 0.02, 0.11, 0.14, 0.12, skin)
    B(ox - 0.08, oy - 0.08, tz + 0.5, 0.16, 0.16, 0.08, skin)
    I(ox, oy, tz + 0.8, 0.3, skin, sub=2)
    I(ox, oy - 0.08, tz + 0.94, 0.3, hair, sub=2, scale=(1.04, 1, 0.7))
    if bun:
        I(ox, oy - 0.1, tz + 1.2, 0.15, hair)
    for dx in (-0.15, 0.08):
        B(ox + dx, oy + 0.26, tz + 0.77, 0.07, 0.04, 0.09, HAIR)


def chair(ox=0, oy=0, color=INDIGO):
    C(ox, oy, 0, 0.24, 0.05, NAVY)
    C(ox, oy, 0.05, 0.04, 0.3, STEEL, seg=6)
    B(ox - 0.25, oy - 0.25, 0.35, 0.5, 0.5, 0.08, color)
    B(ox - 0.25, oy - 0.33, 0.43, 0.5, 0.08, 0.55, color)


def monitor(ox, oy, z, screen, w=0.84):
    B(ox - 0.2, oy - 0.1, z, 0.4, 0.22, 0.03, NAVY)
    B(ox - 0.05, oy, z, 0.1, 0.08, 0.16, NAVY)
    B(ox - w / 2, oy, z + 0.14, w, 0.07, 0.54, NAVY)
    B(ox - w / 2 + 0.04, oy - 0.012, z + 0.18, w - 0.08, 0.02, 0.46, screen, emit=True)
    for i, lw in enumerate((0.4, 0.55, 0.3, 0.48)):
        B(ox - w / 2 + 0.1, oy - 0.02, z + 0.54 - i * 0.09, lw * w, 0.012, 0.035,
          WHITE, emit=True)


def desk(ox=0, oy=0, w=1.8):
    B(ox - w / 2, oy, 0.68, w, 0.8, 0.08, WOOD)
    B(ox - w / 2 + 0.04, oy + 0.05, 0, 0.08, 0.7, 0.68, WOOD_D)
    B(ox + w / 2 - 0.12, oy + 0.05, 0, 0.08, 0.7, 0.68, WOOD_D)
    B(ox + w / 2 - 0.55, oy + 0.08, 0.28, 0.43, 0.64, 0.4, WOOD_D)
    B(ox + w / 2 - 0.42, oy + 0.06, 0.45, 0.16, 0.03, 0.04, MARIGOLD)


def deskset(shirt=SAFFRON, screen=NAVY_L, skin=SKIN[0], hair=HAIR, bun=False,
            seat=INDIGO, mug=SAFFRON):
    chair(0, 0, seat)
    person(0, 0.02, shirt, skin, hair, seated=True, bun=bun)
    desk(0, 0.4)
    monitor(0, 0.95, 0.76, screen)
    B(-0.3, 0.52, 0.76, 0.56, 0.18, 0.03, GREY)
    B(0.36, 0.54, 0.76, 0.1, 0.14, 0.03, WHITE)
    C(0.68, 0.6, 0.76, 0.07, 0.13, mug)
    B(-0.82, 0.5, 0.76, 0.32, 0.24, 0.02, WHITE)
    B(-0.78, 0.84, 0.76, 0.26, 0.2, 0.06, PINK)
    B(-0.76, 0.86, 0.82, 0.22, 0.16, 0.05, TEAL)


def plant(ox=0, oy=0, tall=False):
    C(ox, oy, 0, 0.2, 0.34, POT, seg=6, r2=0.27)
    C(ox, oy, 0.34, 0.28, 0.05, "#C2441F", seg=6)
    if tall:
        C(ox, oy, 0.36, 0.04, 0.7, "#7A5230", seg=5)
        I(ox, oy, 1.3, 0.42, LEAF)
        I(ox + 0.22, oy - 0.1, 1.0, 0.3, LEAF_D)
        I(ox - 0.2, oy + 0.14, 1.55, 0.28, "#57D182")
    else:
        I(ox, oy, 0.62, 0.3, LEAF)
        I(ox + 0.17, oy - 0.08, 0.5, 0.2, LEAF_D)
        I(ox - 0.14, oy + 0.1, 0.8, 0.2, "#57D182")


def rack(ox=0, oy=0, flip=0):
    """Server rack, 1.0 wide, front on the -y side."""
    B(ox, oy, 0, 1.0, 0.9, 2.3, NAVY)
    B(ox - 0.03, oy - 0.03, 2.3, 1.06, 0.96, 0.08, NAVY_L)
    for row in range(8):
        z = 0.2 + row * 0.25
        B(ox + 0.08, oy - 0.02, z, 0.84, 0.03, 0.17, NAVY_L)
        led = GREEN if (row + flip) % 3 else SKY
        B(ox + 0.14, oy - 0.035, z + 0.06, 0.1, 0.02, 0.06, led, emit=True)
        B(ox + 0.28, oy - 0.035, z + 0.06, 0.1, 0.02, 0.06, MARIGOLD, emit=True)
        B(ox + 0.5, oy - 0.035, z + 0.05, 0.36, 0.02, 0.025, STEEL)
        B(ox + 0.5, oy - 0.035, z + 0.1, 0.36, 0.02, 0.025, STEEL)


def crate(ox, oy, z, s, tape=MARIGOLD):
    B(ox, oy, z, s, s, s * 0.8, "#D8A867")
    B(ox + s * 0.4, oy - 0.01, z, s * 0.2, s + 0.02, s * 0.8 + 0.01, tape)


# =====================================================================
# BASE: the empty office — floor, walls, windows, door and wall decor.
# Room interior is x 0..10, y 0..10. Back walls are at x=0 and y=10.
# =====================================================================
LAYER = "base"
B(-0.5, -0.2, -0.75, 10.7, 10.7, 0.3, "#8C6A45")
B(-0.3, 0, -0.45, 10.3, 10.3, 0.45, SLAB)
for i in range(10):
    for j in range(10):
        B(i + 0.02, j + 0.02, 0, 0.96, 0.96, 0.02, FLOOR_A if (i + j) % 2 else FLOOR_B)

# Walls: teal lower band, cream upper, darker cap.
B(-0.3, 0, 0, 0.3, 10.3, 1.0, WALL_BAND)
B(-0.3, 0, 1.0, 0.3, 10.3, 2.2, WALL)
B(-0.34, 0, 3.2, 0.38, 10.34, 0.1, TRIM)
B(0, 10, 0, 10, 0.3, 1.0, WALL_BAND)
B(0, 10, 1.0, 10, 0.3, 2.2, WALL)
B(0, 9.96, 3.2, 10.04, 0.38, 0.1, TRIM)
B(0, 0, 0, 0.05, 10, 0.12, TRIM)
B(0, 9.95, 0, 10, 0.05, 0.12, TRIM)
B(0, 0, 1.0, 0.04, 10, 0.06, WHITE)
B(0, 9.96, 1.0, 10, 0.04, 0.06, WHITE)

# Windows on the right-hand wall (y = 10).
for x0 in (0.8, 5.3):
    B(x0, 9.9, 1.25, 1.9, 0.1, 1.5, WHITE)
    B(x0 + 0.1, 9.88, 1.35, 1.7, 0.04, 1.3, SKY, emit=True)
    B(x0 + 0.92, 9.86, 1.35, 0.06, 0.04, 1.3, WHITE)
    B(x0 + 0.1, 9.86, 1.97, 1.7, 0.04, 0.06, WHITE)
    B(x0 - 0.05, 9.8, 1.2, 2.0, 0.2, 0.06, WHITE)
    B(x0 + 0.3, 9.87, 1.5, 0.5, 0.02, 0.22, WHITE, emit=True)  # cloud
    B(x0 + 1.1, 9.87, 2.25, 0.4, 0.02, 0.16, WHITE, emit=True)

# Door on the left-hand wall (x = 0) with a marigold toran above it.
B(0, 0.7, 0, 0.1, 1.5, 2.45, TRIM)
B(0.06, 0.8, 0, 0.06, 1.3, 2.3, SAFFRON)
B(0.1, 0.9, 1.3, 0.04, 1.1, 0.8, "#FFA865")
B(0.1, 0.9, 0.25, 0.04, 1.1, 0.8, "#FFA865")
C(0.16, 1.9, 1.1, 0.07, 0.07, MARIGOLD, seg=6, rot=(0, 90, 0))
for k in range(9):
    yy = 0.7 + k * 0.1875
    drop = 0.12 * math.sin(k / 8 * math.pi)
    I(0.14, yy, 2.62 - drop, 0.1, MARIGOLD if k % 2 else SAFFRON)
for k in (1, 4, 7):
    I(0.14, 0.7 + k * 0.1875, 2.38 - 0.12 * math.sin(k / 8 * math.pi), 0.07, LEAF)

# Clock, posters and a notice board on the left-hand wall.
C(0.05, 8.9, 2.45, 0.34, 0.08, NAVY, seg=12, rot=(0, 90, 0))
C(0.09, 8.9, 2.45, 0.27, 0.04, WHITE, seg=12, rot=(0, 90, 0))
B(0.11, 8.88, 2.45, 0.02, 0.04, 0.2, RED)
B(0.11, 8.74, 2.43, 0.02, 0.16, 0.04, NAVY)
B(0, 2.7, 1.5, 0.05, 0.8, 1.1, NAVY)
B(0.05, 2.76, 1.56, 0.02, 0.68, 0.98, MARIGOLD)
I(0.08, 3.1, 2.2, 0.17, SAFFRON)
B(0.07, 2.84, 1.66, 0.02, 0.52, 0.1, WHITE)
B(0.07, 2.84, 1.82, 0.02, 0.36, 0.06, WHITE)

# Poster and air conditioner on the right-hand wall.
B(3.2, 9.95, 1.5, 1.2, 0.05, 1.2, NAVY)
B(3.26, 9.93, 1.56, 1.08, 0.02, 1.08, PINK)
for k, hh in enumerate((0.25, 0.45, 0.62, 0.85)):
    B(3.38 + k * 0.23, 9.91, 1.66, 0.16, 0.02, hh, WHITE)
B(7.7, 9.7, 2.45, 1.6, 0.3, 0.5, WHITE)
B(7.78, 9.68, 2.5, 1.44, 0.03, 0.08, GREY)
B(7.78, 9.68, 2.62, 1.44, 0.03, 0.04, GREY)
B(9.1, 9.68, 2.8, 0.1, 0.03, 0.06, GREEN, emit=True)

# Corner plants and a water cooler that never get covered.
plant(0.55, 9.45, tall=True)
B(9.2, 9.3, 0, 0.6, 0.55, 1.1, WHITE)
B(9.25, 9.27, 0.55, 0.5, 0.04, 0.3, GREY)
C(9.5, 9.58, 1.1, 0.24, 0.6, SKY, seg=8)
C(9.5, 9.58, 1.7, 0.12, 0.1, "#5DBBE3", seg=8)
B(9.33, 9.25, 0.72, 0.08, 0.05, 0.06, RED)
B(9.6, 9.25, 0.72, 0.08, 0.05, 0.06, "#3D7BFF")

# =====================================================================
# CLOUD PLATFORM: server racks along the right-hand wall.
# =====================================================================
LAYER = "cloud"
B(1.0, 8.0, 0.02, 4.0, 1.9, 0.08, "#55617F")
for i in range(8):
    B(1.05 + i * 0.5, 8.0, 0.1, 0.02, 1.9, 0.005, NAVY)
for i in range(3):
    rack(1.3 + i * 1.2, 8.75, flip=i)
B(1.2, 8.9, 2.6, 3.6, 0.5, 0.08, STEEL)
for i in range(3):
    B(1.75 + i * 1.2, 9.1, 2.38, 0.08, 0.08, 0.24, MARIGOLD)
    B(1.9 + i * 1.2, 9.1, 2.38, 0.08, 0.08, 0.24, "#3D7BFF")
place(person, 2.4, 7.3, deg=215, s=1.15, shirt=TEAL, skin=SKIN[1])
crate(4.2, 7.4, 0, 0.5, tape=SKY)
crate(4.25, 7.45, 0.4, 0.38, tape=GREEN)

# =====================================================================
# SAAS PRODUCT: a team at desks under a whiteboard on the left wall.
# =====================================================================
LAYER = "saas"
B(0, 4.2, 1.35, 0.06, 2.6, 1.5, STEEL)
B(0.06, 4.28, 1.43, 0.02, 2.44, 1.34, WHITE)
for k, hh in enumerate((0.3, 0.5, 0.42, 0.7, 0.9)):
    B(0.08, 4.45 + k * 0.24, 1.6, 0.02, 0.16, hh, (TEAL, GREEN, MARIGOLD, SAFFRON, PINK)[k])
B(0.08, 5.8, 2.35, 0.02, 0.26, 0.26, MARIGOLD)
B(0.08, 6.12, 2.35, 0.02, 0.26, 0.26, PINK)
B(0.08, 5.8, 2.02, 0.02, 0.26, 0.26, SKY)
B(0.08, 6.12, 1.7, 0.02, 0.26, 0.26, GREEN)
B(0.08, 5.8, 1.62, 0.02, 0.5, 0.04, NAVY)
B(0.06, 4.3, 1.3, 0.12, 2.4, 0.05, STEEL)
place(deskset, 2.6, 4.2, deg=90, s=1.1, shirt=INDIGO, screen="#1F3A5F", skin=SKIN[2])
place(deskset, 2.6, 6.3, deg=90, s=1.1, shirt=PINK, screen="#1F3A5F", bun=True,
      seat=TEAL, mug=WHITE)
place(person, 1.0, 3.3, deg=-70, s=1.15, shirt=MARIGOLD, skin=SKIN[1])
B(0.1, 7.2, 0, 0.6, 0.8, 0.75, WHITE)  # printer table
B(0.15, 7.3, 0.75, 0.5, 0.6, 0.22, GREY)
B(0.6, 7.4, 0.8, 0.2, 0.4, 0.02, WHITE)

# =====================================================================
# AI LAB: a robot, a glowing core and a researcher.
# =====================================================================
LAYER = "ai"
C(7.5, 7.9, 0.02, 1.6, 0.06, "#D9D2FF", seg=8)
C(7.5, 7.9, 0.08, 1.25, 0.04, INDIGO, seg=8)
C(7.5, 7.9, 0.12, 0.6, 0.5, NAVY, seg=6, r2=0.45)
C(7.5, 7.9, 0.62, 0.5, 0.08, PINK, seg=6, emit=True)
C(7.5, 7.9, 0.7, 0.08, 0.7, STEEL, seg=6)
I(7.5, 7.9, 2.0, 0.5, "#B9A8FF", sub=1, emit=True)
I(7.5, 7.9, 2.0, 0.34, WHITE, sub=1, emit=True)
C(7.5, 7.9, 1.25, 0.62, 0.06, PINK, seg=8, emit=True)
for k in range(6):
    a = k * math.pi / 3
    B(7.5 + 0.85 * math.cos(a) - 0.06, 7.9 + 0.85 * math.sin(a) - 0.06, 0.12,
      0.12, 0.12, 0.45 + 0.2 * (k % 2), STEEL)
    I(7.5 + 0.85 * math.cos(a), 7.9 + 0.85 * math.sin(a), 0.67 + 0.2 * (k % 2),
      0.09, SKY, emit=True)


def robot():
    B(-0.3, -0.25, 0, 0.6, 0.5, 0.14, NAVY)
    for dx in (-0.36, 0.26):
        C(dx + 0.05, 0, 0.14, 0.14, 0.1, NAVY_L, seg=8, rot=(0, 90, 0))
    B(-0.28, -0.2, 0.14, 0.56, 0.4, 0.62, WHITE)
    B(-0.16, 0.2, 0.36, 0.32, 0.02, 0.22, SKY, emit=True)
    B(-0.08, -0.08, 0.76, 0.16, 0.16, 0.08, STEEL)
    B(-0.34, -0.24, 0.84, 0.68, 0.48, 0.46, WHITE)
    B(-0.27, 0.24, 0.9, 0.54, 0.02, 0.32, NAVY)
    B(-0.18, 0.26, 1.02, 0.1, 0.02, 0.12, GREEN, emit=True)
    B(0.08, 0.26, 1.02, 0.1, 0.02, 0.12, GREEN, emit=True)
    B(-0.02, -0.02, 1.3, 0.04, 0.04, 0.22, STEEL)
    I(0, 0, 1.56, 0.08, RED, emit=True)
    for dx in (-0.42, 0.3):
        B(dx, -0.07, 0.3, 0.12, 0.14, 0.42, STEEL)
        B(dx, -0.07, 0.3, 0.12, 0.4, 0.12, STEEL)


place(robot, 5.9, 7.6, deg=215, s=1.2)
place(person, 9.1, 6.9, deg=215, s=1.15, shirt=WHITE, skin=SKIN[0], bun=True,
      pants=INDIGO)
for hx, hy, hc in ((8.9, 8.9, SKY), (6.6, 9.2, "#B9A8FF")):
    B(hx, hy, 0, 0.08, 0.08, 1.3, STEEL)
    B(hx - 0.4, hy - 0.03, 1.3, 0.9, 0.05, 0.6, NAVY)
    B(hx - 0.35, hy - 0.045, 1.35, 0.8, 0.02, 0.5, hc, emit=True)
    for k, hh in enumerate((0.15, 0.3, 0.22, 0.38)):
        B(hx - 0.28 + k * 0.18, hy - 0.055, 1.4, 0.1, 0.012, hh, WHITE, emit=True)

# =====================================================================
# MOBILE APP: two developers, a giant phone and a designer.
# =====================================================================
LAYER = "app"
B(4.0, 2.2, 0.02, 3.4, 3.4, 0.03, "#BFF0E4")
B(4.15, 2.35, 0.05, 3.1, 3.1, 0.01, TEAL)
place(deskset, 6.7, 3.0, deg=90, s=1.1, shirt=SAFFRON, screen="#143D3A", skin=SKIN[1],
      seat=NAVY_L)
plant(4.4, 2.6)


def big_phone():
    B(-0.5, -0.3, 0, 1.0, 0.6, 0.12, NAVY)
    B(-0.45, -0.08, 0.12, 0.9, 0.16, 1.7, NAVY)
    B(-0.39, -0.1, 0.2, 0.78, 0.03, 1.54, WHITE, emit=True)
    cols = [SAFFRON, TEAL, PINK, GREEN, INDIGO, MARIGOLD, PINK, SKY, GREEN,
            SAFFRON, MARIGOLD, INDIGO]
    for k, c in enumerate(cols):
        B(-0.33 + (k % 3) * 0.24, -0.115, 1.42 - (k // 3) * 0.26, 0.18, 0.02, 0.18,
          c, emit=True)
    B(-0.33, -0.115, 0.3, 0.66, 0.02, 0.22, NAVY_L, emit=True)
    B(-0.12, -0.115, 1.66, 0.24, 0.02, 0.04, NAVY)


place(big_phone, 4.7, 4.9, deg=20, s=1.25)
place(person, 6.3, 5.0, deg=215, s=1.15, shirt=PINK, skin=SKIN[2], bun=True,
      pants="#5A3E8C")

# =====================================================================
# FREELANCE GIGS: the founder's first desk, with moving boxes.
# =====================================================================
LAYER = "freelance"
C(2.3, 1.6, 0.02, 1.5, 0.03, SAFFRON, seg=10)
C(2.3, 1.6, 0.05, 1.2, 0.01, "#FFD08A", seg=10)
C(2.3, 1.6, 0.06, 0.8, 0.01, PINK, seg=10)


def founder_desk():
    chair(0, 0, SAFFRON)
    person(0, 0.02, INDIGO, SKIN[1], seated=True)
    desk(0, 0.4, w=1.5)
    # Laptop instead of a monitor.
    B(-0.3, 0.6, 0.76, 0.6, 0.4, 0.03, GREY)
    B(-0.3, 0.98, 0.78, 0.6, 0.04, 0.4, GREY)
    B(-0.26, 0.97, 0.82, 0.52, 0.02, 0.32, "#1F3A5F", emit=True)
    for i, lw in enumerate((0.3, 0.4, 0.22)):
        B(-0.22, 0.96, 1.05 - i * 0.08, lw, 0.012, 0.03, GREEN, emit=True)
    C(0.52, 0.62, 0.76, 0.07, 0.12, WHITE)  # chai glass
    C(0.52, 0.62, 0.78, 0.055, 0.11, "#B5651D")
    B(-0.68, 0.55, 0.76, 0.26, 0.26, 0.02, MARIGOLD)
    B(-0.66, 0.86, 0.76, 0.2, 0.2, 0.02, PINK)


place(founder_desk, 2.2, 1.0, deg=0, s=1.1)
# Floor lamp.
C(3.7, 2.9, 0, 0.2, 0.05, NAVY)
C(3.7, 2.9, 0.05, 0.03, 1.5, STEEL, seg=5)
C(3.7, 2.9, 1.5, 0.28, 0.35, MARIGOLD, seg=8, r2=0.16, emit=True)
# Moving boxes and a small bookshelf.
crate(0.5, 0.4, 0, 0.6)
crate(0.55, 0.45, 0.48, 0.45, tape=PINK)
crate(1.2, 0.3, 0, 0.42, tape=TEAL)
B(0.3, 2.9, 0, 0.9, 0.35, 1.3, WOOD_D)
for k in range(3):
    B(0.34, 2.88, 0.1 + k * 0.4, 0.82, 0.3, 0.04, WOOD)
    for b, c in enumerate((RED, TEAL, MARIGOLD, INDIGO, GREEN)[k:k + 3]):
        B(0.4 + b * 0.16, 2.9, 0.14 + k * 0.4, 0.12, 0.24, 0.28, c)
I(0.9, 3.05, 1.42, 0.12, RED)  # cricket ball on the shelf
B(1.3, 3.0, 0, 0.14, 0.05, 1.0, "#E8C98A", rz=12)  # cricket bat
B(1.34, 3.0, 1.0, 0.06, 0.05, 0.3, NAVY, rz=12)

# =====================================================================
# FRONT: the chai corner and lounge, always drawn on top.
# =====================================================================
LAYER = "front"
C(8.2, 1.9, 0.02, 1.7, 0.03, INDIGO, seg=8)
C(8.2, 1.9, 0.05, 1.35, 0.01, MARIGOLD, seg=8)
C(8.2, 1.9, 0.06, 1.0, 0.01, PINK, seg=8)
C(8.2, 1.9, 0.07, 0.55, 0.01, WHITE, seg=8)
# Low table with a carrom board.
B(7.7, 1.4, 0, 1.0, 1.0, 0.35, WOOD_D)
B(7.6, 1.3, 0.35, 1.2, 1.2, 0.06, NAVY)
B(7.68, 1.38, 0.41, 1.04, 1.04, 0.01, "#F2D6A0")
for dx, dy, c in ((0, 0, RED), (0.14, 0.05, WHITE), (-0.1, 0.12, NAVY),
                  (0.05, -0.15, WHITE), (-0.14, -0.08, NAVY), (0.3, 0.28, WHITE)):
    C(8.2 + dx, 1.9 + dy, 0.42, 0.055, 0.02, c)
# Bean bags.
I(6.9, 1.2, 0.3, 0.5, SAFFRON, sub=1, scale=(1, 1, 0.65))
I(8.4, 0.55, 0.3, 0.5, TEAL, sub=1, scale=(1, 1, 0.65))
# Chai counter against the front-right edge.
B(9.2, 1.2, 0, 0.7, 2.2, 0.9, WOOD)
B(9.15, 1.15, 0.9, 0.8, 2.3, 0.06, WHITE)
B(9.2, 1.2, 0.1, 0.02, 2.2, 0.06, WOOD_D)
C(9.55, 3.0, 0.96, 0.17, 0.26, STEEL, seg=8, r2=0.12)  # kettle
C(9.55, 3.0, 1.22, 0.06, 0.06, NAVY, seg=6)
B(9.3, 2.97, 1.08, 0.14, 0.06, 0.05, STEEL)
for k in range(4):
    C(9.4 + (k % 2) * 0.18, 2.35 + (k // 2) * 0.18, 0.96, 0.055, 0.12, "#B5651D")
for k in range(3):  # steel tiffin
    C(9.55, 1.6, 0.96 + k * 0.14, 0.15, 0.13, STEEL if k % 2 else GREY, seg=10)
B(9.52, 1.45, 1.38, 0.06, 0.3, 0.03, NAVY)
plant(9.5, 0.5)
place(person, 8.75, 2.75, deg=250, s=1.15, shirt=RED, skin=SKIN[0], hair="#4A2C17")
C(8.42, 2.62, 0.72, 0.05, 0.1, "#B5651D")

# =====================================================================
# Rendering
# =====================================================================
meshes = [o for o in bpy.data.objects if o.type == "MESH"]
ZONES = ["cloud", "saas", "ai", "app", "freelance"]
ROOM_TARGET = Vector((5, 5, 1.35))
ROOM_SCALE = 15.0
ROOM_RES = (1560, 1170)


def shoot(path, res, target, scale):
    cam.location = Vector(target) - VIEW * 40
    cam_data.ortho_scale = scale
    scene.render.resolution_x, scene.render.resolution_y = res
    scene.render.filepath = path
    bpy.ops.render.render(write_still=True)


def show(layers, catchers=()):
    for o in meshes:
        o.hide_render = o["layer"] not in layers and o["layer"] not in catchers
        o.is_shadow_catcher = o["layer"] in catchers


def bounds(layer):
    pts = [o.matrix_basis @ Vector(c) for o in meshes if o["layer"] == layer
           for c in o.bound_box]
    lo = Vector(min(p[i] for p in pts) for i in range(3))
    hi = Vector(max(p[i] for p in pts) for i in range(3))
    return lo, hi


RIGHT = Vector((0.7071, 0.7071, 0))
UP = Vector((-0.3536, 0.3536, 0.866))

if PREVIEW:
    show(["base", "front"] + ZONES)
    shoot(PREVIEW, ROOM_RES, ROOM_TARGET, ROOM_SCALE)
else:
    show(["base"])
    shoot(f"{OUT}/office_base.png", ROOM_RES, ROOM_TARGET, ROOM_SCALE)
    for name in ZONES + ["front"]:
        show([name], catchers=["base"])
        shoot(f"{OUT}/office_{name}.png", ROOM_RES, ROOM_TARGET, ROOM_SCALE)
    for name in ZONES:
        lo, hi = bounds(name)
        mid = (lo + hi) / 2
        corners = [Vector((x, y, z)) - mid for x in (lo.x, hi.x) for y in (lo.y, hi.y)
                   for z in (lo.z, hi.z)]
        span = 2 * max(max(abs(c.dot(RIGHT)), abs(c.dot(UP))) for c in corners)
        show([name])
        shoot(f"{OUT}/icon_{name}.png", (512, 512), mid, span * 1.04)
        # Where the zone sits in the office picture, as fractions of its size.
        d = Vector((mid.x, mid.y, hi.z)) - ROOM_TARGET
        print(f"ZONE {name} u={0.5 + d.dot(RIGHT) / ROOM_SCALE:.3f} "
              f"v={0.5 - d.dot(UP) / (ROOM_SCALE * ROOM_RES[1] / ROOM_RES[0]):.3f}")

    # Manager portrait: head and shoulders, facing the camera.
    for o in meshes:
        o.hide_render = True
    LAYER = "manager"
    place(person, 0, 0, deg=-135, shirt=NAVY, skin=SKIN[1])
    B(-0.03, -0.03, 0.62, 0.06, 0.06, 0.3, MARIGOLD)
    shoot(f"{OUT}/manager.png", (256, 256), (0, 0, 1.2), 1.25)
