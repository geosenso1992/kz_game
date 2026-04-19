import os
from PIL import Image

# Pixels die lichter zijn dan deze waarde worden als achtergrond gezien
BACKGROUND_THRESHOLD = 245

# Hoe tolerant we zijn voor bijna-grijze achtergrond
COLOR_TOLERANCE = 18


def is_near_white_or_gray(pixel, threshold=BACKGROUND_THRESHOLD, tolerance=COLOR_TOLERANCE):
    """Check of een pixel waarschijnlijk achtergrond is:
    - heel licht
    - en de RGB-waarden liggen dicht bij elkaar
    """
    r, g, b, a = pixel

    # Volledig transparant laten we gewoon staan
    if a == 0:
        return False

    is_light = r >= threshold and g >= threshold and b >= threshold
    is_grayish = abs(r - g) <= tolerance and abs(r - b) <= tolerance and abs(g - b) <= tolerance

    return is_light and is_grayish


def remove_light_background(img, threshold=BACKGROUND_THRESHOLD, tolerance=COLOR_TOLERANCE):
    """Maak lichte / witte / checkerboard-achtige achtergrond transparant."""
    img = img.convert("RGBA")
    pixels = list(img.getdata())
    new_pixels = []

    for pixel in pixels:
        if is_near_white_or_gray(pixel, threshold, tolerance):
            new_pixels.append((255, 255, 255, 0))  # transparant
        else:
            new_pixels.append(pixel)

    cleaned = Image.new("RGBA", img.size)
    cleaned.putdata(new_pixels)
    return cleaned


def autocrop_transparent(img, padding=10):
    """Snijd overtollige transparante randen weg."""
    bbox = img.getbbox()
    if not bbox:
        return img

    left, upper, right, lower = bbox

    left = max(0, left - padding)
    upper = max(0, upper - padding)
    right = min(img.width, right + padding)
    lower = min(img.height, lower + padding)

    return img.crop((left, upper, right, lower))


def prepare_image(img, remove_background=True, crop=True):
    """Optionele opschoning vóór resize."""
    img = img.convert("RGBA")

    if remove_background:
        img = remove_light_background(img)

    if crop:
        img = autocrop_transparent(img)

    return img


def clean_master_images(input_folder, remove_background=True):
    """Maak de master-afbeeldingen zelf transparant en overschrijf ze."""
    if not os.path.exists(input_folder):
        print(f"⚠️ Skipped (not found): {input_folder}")
        return

    for filename in os.listdir(input_folder):
        if filename.lower().endswith(".png"):
            img_path = os.path.join(input_folder, filename)
            img = Image.open(img_path)

            # Bij master willen we NIET croppen, alleen achtergrond verwijderen
            img = prepare_image(img, remove_background=remove_background, crop=False)

            img.save(img_path)
            print(f"Cleaned master: {filename}")

    print(f"Done cleaning master images for {input_folder}")


def create_icons(input_folder, output_folder, canvas_size=1024, icon_size=(300, 300), remove_background=True):
    if not os.path.exists(input_folder):
        print(f"⚠️ Skipped (not found): {input_folder}")
        return

    os.makedirs(output_folder, exist_ok=True)

    for filename in os.listdir(input_folder):
        if filename.lower().endswith(".png"):
            img_path = os.path.join(input_folder, filename)
            img = Image.open(img_path)

            img = prepare_image(img, remove_background=remove_background, crop=True)

            # Maak vierkante transparante canvas
            square = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
            img.thumbnail((canvas_size, canvas_size), Image.LANCZOS)

            x = (canvas_size - img.width) // 2
            y = (canvas_size - img.height) // 2
            square.paste(img, (x, y), img)

            # Resize naar icon formaat
            final = square.resize(icon_size, Image.LANCZOS)

            output_path = os.path.join(output_folder, filename)
            final.save(output_path)

            print(f"Processed: {filename}")

    print(f"Done processing {input_folder}")


def create_silhouette_icons(input_folder, output_folder, canvas_size=1024, icon_size=(300, 300), remove_background=True):
    """Create dark silhouette versions of animal icons for the map."""
    if not os.path.exists(input_folder):
        print(f"⚠️ Skipped (not found): {input_folder}")
        return

    os.makedirs(output_folder, exist_ok=True)

    for filename in os.listdir(input_folder):
        if filename.lower().endswith(".png"):
            img_path = os.path.join(input_folder, filename)
            img = Image.open(img_path)

            img = prepare_image(img, remove_background=remove_background, crop=True)

            # Pak alpha channel van opgeschoonde afbeelding
            _, _, _, a = img.split()

            silhouette = Image.merge("RGBA", (
                Image.new("L", img.size, 51),  # R
                Image.new("L", img.size, 51),  # G
                Image.new("L", img.size, 51),  # B
                a
            ))

            # Maak vierkante canvas
            square = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
            silhouette.thumbnail((canvas_size, canvas_size), Image.LANCZOS)

            x = (canvas_size - silhouette.width) // 2
            y = (canvas_size - silhouette.height) // 2
            square.paste(silhouette, (x, y), silhouette)

            # Resize naar icon formaat
            final = square.resize(icon_size, Image.LANCZOS)

            output_path = os.path.join(output_folder, filename)
            final.save(output_path)

            print(f"Created silhouette: {filename}")

    print(f"Done creating silhouettes for {input_folder}")


# 🔥 Eerst master-afbeeldingen zelf opschonen
clean_master_images(
    "assets/animals/master",
    remove_background=True
)

# 🔥 Animals icons
create_icons(
    "assets/animals/master",
    "assets/animals/icons_300",
    remove_background=False
)

# 🔥 Animals silhouette versions
create_silhouette_icons(
    "assets/animals/master",
    "assets/animals/icons_300_silhouette",
    remove_background=False
)

# 🔥 Seeds
create_icons(
    "assets/seeds/master",
    "assets/seeds/icons_300",
    remove_background=True
)

# 🔥 Fruits
create_icons(
    "assets/fruits/master",
    "assets/fruits/icons_300",
    remove_background=True
)