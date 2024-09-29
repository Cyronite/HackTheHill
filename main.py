from PIL import Image

def rgb_to_ycbcr_10bit(R, G, B):
    # Step 1: Convert RGB to YCbCr (8-bit range)
    Y = 0.299 * R + 0.587 * G + 0.114 * B
    Cb = 128 + (-0.168736 * R - 0.331264 * G + 0.5 * B)
    Cr = 128 + (0.5 * R - 0.418688 * G - 0.081312 * B)

    # Step 2: Scale to 10-bit (multiply by 4)
    Y_10bit = round(Y * 4)
    Cb_10bit = round(Cb * 4)
    Cr_10bit = round(Cr * 4)

    # Step 3: Clip the values to ensure they are in the 10-bit range (0 to 1023)
    Y_10bit = min(1023, max(0, Y_10bit))
    Cb_10bit = min(1023, max(0, Cb_10bit))
    Cr_10bit = min(1023, max(0, Cr_10bit))

    Y_binary = format(Y_10bit, '010b')
    Cb_binary = format(Cb_10bit, '010b')
    Cr_binary = format(Cr_10bit, '010b')

    return Y_binary, Cb_binary, Cr_binary

def process_image(input_image_path, output_file_path, resized_image_path):
    # Step 1: Open the image
    try:
        image = Image.open(input_image_path)
    except Exception as e:
        print(f"Error opening image: {e}")
        return

    # Ensure the image is in RGB mode
    if image.mode != 'RGB':
        image = image.convert('RGB')

    # Resize to 48x27 pixels (1920/40 and 1080/40)
    image_resized = image.resize((48, 27))

    # Step 2: Save the resized image
    image_resized.save(resized_image_path)

    # Step 3: Open the output file
    with open(output_file_path, 'w') as file:
        # Step 4: Process each pixel
        for y in range(image_resized.height):
            for x in range(image_resized.width):
                R, G, B = image_resized.getpixel((x, y))
                Y, Cb, Cr = rgb_to_ycbcr_10bit(R, G, B)
                # Step 5: Write to the output file in the specified format
                file.write(f"{Y}{Cr}\n{Y}{Cb}\n")
       
# Example usage
input_image_path = r'C:\Code\Python\IMG_RGB_TO_LUMACHROMA\images\image.png'  # Replace with your input image path
output_file_path = 'ottawasmaller.txt'
resized_image_path = r'C:\Code\Python\IMG_RGB_TO_LUMACHROMA\output\ottawa_48x27.png'  # Path to save the resized image
process_image(input_image_path, output_file_path, resized_image_path)

print("Processing complete. Check the resized image and output.txt for results.")
