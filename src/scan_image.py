from PIL import Image
import colorsys
import sys
import random

DISPLAY = False
IMAGE_PATH = 'res/surprised_pikachu.png'
OUTPUT_DIMS = int(sys.argv[1])
ABSTRACTION = 1  # 1 is normal. Please leave at 1.
COLOURS = {
    'I': (0.833, 1.0, 0.776),  # Magenta
    'O': (0.0, 1.0, 0.776),  # Red
    'J': (0.167, 1.0, 0.776),  # Yellow
    'L': (0.333, 1.0, 0.776),  # Green
    'S': (0.5, 1.0, 0.776),  # Cyan
    'T': (0.667, 1.0, 0.776),  # Blue
    'Z': (0.0, 0.0, 0.0),  # Black
    'W': (0.0, 0.0, 0.776)  # White
}


def run():
    image = Image.open(IMAGE_PATH)
    pixels = image.load()
    width, height = image.size

    all_colours = get_all_colours(pixels, width, height)

    arrange_colours(all_colours)

    short_colour_spread = get_short_colour_spread(all_colours)

    pixel_ids = get_output_ids(pixels, short_colour_spread, width, height)

    update_spread_count(short_colour_spread, pixel_ids)

    add_code_map_to_colour_spread(short_colour_spread)

    output_code_array = get_output_codes(pixel_ids, short_colour_spread)

    if DISPLAY:
        display_image(short_colour_spread, pixel_ids)

    write_blocks_to_file(output_code_array)


def get_all_colours(pixels, width, height):
    all_colours = []
    for i in range(width):
        for j in range(height):
            all_colours.append(get_hsv(pixels[i, j]))
    return all_colours


def display_image(colour_spread, pixel_ids):
    output_image = Image.new('RGB', (OUTPUT_DIMS, OUTPUT_DIMS), 'white')
    output_to_mod = output_image.load()
    for i in range(OUTPUT_DIMS):
        for j in range(OUTPUT_DIMS):
            output_to_mod[j, i] = get_rgb(COLOURS[colour_spread[pixel_ids[i][j]]['code']])
    output_image.show()


def get_output_ids(pixels, short_colour_spread, width, height):
    if width <= height:
        pixel_step = int(width / OUTPUT_DIMS)
    else:
        pixel_step = int(height / OUTPUT_DIMS)

    output_pixels = []
    for i in range(OUTPUT_DIMS):
        sample_y = (i * pixel_step) + int(pixel_step / 2)
        pixel_row = []
        for j in range(OUTPUT_DIMS):
            sample_x = (j * pixel_step) + int(pixel_step / 2)
            pixel_row.append(get_closest_colour_id(short_colour_spread, get_hsv(pixels[sample_x, sample_y])))
        output_pixels.append(pixel_row)

    return output_pixels


def get_output_codes(pixel_ids, short_colour_spread):
    output_codes = []
    for pixel_row in pixel_ids:
        output_row = []
        for pixel_id in pixel_row:
            output_row.append(short_colour_spread[pixel_id]['code'])
        output_codes.append(output_row)
    return output_codes


def update_spread_count(colour_spread, output_pixels):
    for colour_id, spread_colour in colour_spread.items():
        spread_colour['count'] = sum(1 for pixel_row in output_pixels
                                     for pixel_id in pixel_row if pixel_id == colour_id)


def calc_colour_distance(spread_hsv, pixel_hsv):
    dh = abs(min(abs(pixel_hsv[0] - spread_hsv[0]), 1 - abs(pixel_hsv[0] - spread_hsv[0]) / 0.5))
    ds = abs(pixel_hsv[1] - spread_hsv[1])
    dv = abs(pixel_hsv[2] - spread_hsv[2])

    return (dh ** 2 + ds ** 2 + dv ** 2) ** 0.5


def get_closest_colour_id(colour_spread, pixel_hsv):
    return_id = 0
    hue_min_distance = calc_colour_distance(colour_spread[0]['hsv'], pixel_hsv)
    for colour_id, colour_dict in colour_spread.items():
        hue_distance = calc_colour_distance(colour_dict['hsv'], pixel_hsv)
        if hue_distance < hue_min_distance:
            hue_min_distance = hue_distance
            return_id = colour_id
    return return_id


def add_code_map_to_colour_spread(colour_spread):
    colour_preference_list = []
    for colour_id, colour_dict in colour_spread.items():
        for colour_code, colour_hsv in COLOURS.items():
            dist = calc_colour_distance(colour_hsv, colour_dict['hsv'])
            colour_preference_list.append({'id': colour_id, 'code': colour_code, 'dist': dist})

    colour_preference_list.sort(key=lambda pref: pref['dist'])

    for _ in range(len(COLOURS)):
        colour_choice = colour_preference_list[0]
        colour_spread[colour_choice['id']]['code'] = colour_choice['code']
        colour_preference_list = [item for item in colour_preference_list if item['id'] is not colour_choice['id']
                                  and item['code'] is not colour_choice['code']]

    # Leftover items get assigned randomly creating pattern effect
    for spread_id, spread_dict in colour_spread.items():
        if len(spread_dict['code']) == 0:
            spread_dict['code'] = random.choice(list(COLOURS.keys()))


def get_short_colour_spread(colours):
    spread_separation = int(len(colours) / (len(COLOURS) * ABSTRACTION))
    short_colour_spread = {}
    for i in range(len(COLOURS) * ABSTRACTION):
        sample_point = (i * spread_separation) + int(spread_separation / 2)
        short_colour_spread[i] = {'hsv': colours[sample_point], 'count': 0, 'code': ''}
    return short_colour_spread


def get_hsv(pixel_tuple):
    return colorsys.rgb_to_hsv(
        pixel_tuple[0] / 255.0,
        pixel_tuple[1] / 255.0,
        pixel_tuple[2] / 255.0)


def get_rgb(hsv):
    rgb = colorsys.hsv_to_rgb(hsv[0], hsv[1], hsv[2])
    return int(255 * rgb[0]), int(255 * rgb[1]), int(255 * rgb[2])


def arrange_colours(colours):
    colours.sort(key=lambda colour: sum(colour), reverse=True)


def write_blocks_to_file(output_pixels):
    with open('res/picture_codes.txt', 'w') as output_file:
        for row in output_pixels:
            line = ''
            for cell in row:
                line += cell
            output_file.write(line + '\n')


if __name__ == '__main__':
    run()
