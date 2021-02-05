from PIL import Image
import colorsys
import sys

OUTPUT_DIMS = int(sys.argv[1])
OUTPUT_CODES = ["I", "O", "J", "L", "S", "T", "Z"]


def run():
    write_blocks_to_file(load_image('surprised_pikachu.png'))


def load_image(path):
    image = Image.open(path)
    pixels = image.load()
    x, y = image.size

    all_colours = []
    for i in range(x):
        for j in range(y):
            pixel_rgb = pixels[i, j]
            all_colours.append({
                'r': pixel_rgb[0],
                'g': pixel_rgb[1],
                'b': pixel_rgb[2]
            })
    arrange_colours(all_colours)

    short_colour_spread = get_short_colour_spread(all_colours, len(OUTPUT_CODES))
    add_code_map_to_colour_spread(short_colour_spread)
    pixel_step = int(x / OUTPUT_DIMS)

    output_image = Image.new('RGB', (OUTPUT_DIMS, OUTPUT_DIMS), 'white')
    output_to_mod = output_image.load()

    output_pixels = []
    for i in range(OUTPUT_DIMS):
        sample_y = (i * pixel_step) + int(pixel_step / 2)
        pixel_row = []
        for j in range(OUTPUT_DIMS):
            sample_x = (j * pixel_step) + int(pixel_step / 2)
            colour_code = get_colour_code(short_colour_spread, pixels[sample_x, sample_y])
            pixel_row.append(colour_code)
            output_to_mod[j, i] = get_rgb_from_code(short_colour_spread, colour_code)
        output_pixels.append(pixel_row)

    return output_pixels


def calc_colour_distance(spread_hsv, pixel_hsv):
    dh = min(abs(pixel_hsv[0] - spread_hsv[0]),
             1 - abs(pixel_hsv[0] - spread_hsv[0]) / 0.5)

    ds = abs(pixel_hsv[1] - spread_hsv[1])

    dv = abs(pixel_hsv[2] - spread_hsv[2])

    return (2 * dh ** 2 + ds ** 2 + dv ** 2) ** 0.5


def get_colour_code(colour_spread, pixel):
    hsv = get_hsv_from_tuple(pixel)
    code = colour_spread[0]['code']
    hue_min_distance = calc_colour_distance(get_hsv(colour_spread[0]), hsv)
    for colour_dict in colour_spread:
        hue_distance = calc_colour_distance(get_hsv(colour_dict), hsv)
        if hue_distance < hue_min_distance:
            hue_min_distance = hue_distance
            code = colour_dict['code']
    return code


def get_rgb_from_code(colour_spread, code):
    for colour_dict in colour_spread:
        if colour_dict['code'] == code:
            return (colour_dict['r'], colour_dict['g'], colour_dict['b'])
    return (0, 0, 0)


def add_code_map_to_colour_spread(colour_spread):
    count = 0
    for colour_dict in colour_spread:
        colour_dict['code'] = OUTPUT_CODES[count]
        count += 1


def get_short_colour_spread(colours, colours_out_count):
    arrange_colours(colours)
    total_pixels = len(colours)
    spread_separation = int(total_pixels / colours_out_count)
    short_colour_spread = []
    for i in range(colours_out_count):
        sample_point = (i * spread_separation) + int(spread_separation / 2)
        short_colour_spread.append(colours[sample_point])

    return short_colour_spread


def get_hsv_from_tuple(pixel_tuple):
    return colorsys.rgb_to_hsv(
        pixel_tuple[0] / 255.0,
        pixel_tuple[1] / 255.0,
        pixel_tuple[2] / 255.0
    )


def get_hsv(colour_dict):
    return get_hsv_from_tuple(
        (colour_dict['r'],
         colour_dict['g'],
         colour_dict['b']))


def arrange_colours(colours):
    colours.sort(key=lambda colour: sum(get_hsv(colour)), reverse=True)


def write_blocks_to_file(output_pixels):
    with open('picture_codes.txt', 'w') as output_file:
        for row in output_pixels:
            line = ''
            for cell in row:
                line += cell
            output_file.write(line + '\n')


if __name__ == '__main__':
    run()
