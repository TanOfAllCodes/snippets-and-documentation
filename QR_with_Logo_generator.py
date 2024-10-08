# 1. Import the necessary libraries
import qrcode
from PIL import Image

# 2. Define variables
data = "ENTER LINK HERE"
qr_code_file = "ENTER OUTPUT FILE HERE"
logo_file = "ENTER LOGO FILE HERE"

qr_size_factor = 3

# 3. Create a QRCode object
qr = qrcode.QRCode(
    version=1,
    error_correction=qrcode.constants.ERROR_CORRECT_H,  # Higher error correction
    box_size=10 * qr_size_factor,  # Triple the size of each box
    border=1 * qr_size_factor,  # Triple the border size
)

# 4. Add data to the QR code
qr.add_data(data)
qr.make(fit=True)

# 5. Create an image from the QR Code instance
img = qr.make_image(fill='black', back_color='white').convert('RGB')

# 6. Load the logo image
logo = Image.open(logo_file)

# 7. Ensure logo has an alpha channel
if logo.mode != 'RGBA':
    logo = logo.convert('RGBA')

# 8. Calculate logo size and position
logo_size = (img.size[0] // 5, img.size[1] // 5)
logo = logo.resize(logo_size, Image.LANCZOS)

# 9. Create a white background for the logo
white_box_size = (logo_size[0] + 20 * qr_size_factor, logo_size[1] + 20 * qr_size_factor)  # Add padding around the logo
white_box = Image.new('RGBA', white_box_size, (255, 255, 255, 255))

# 10. Calculate the position to paste the logo onto the white box
logo_position = ((white_box_size[0] - logo_size[0]) // 2, (white_box_size[1] - logo_size[1]) // 2)
white_box.paste(logo, logo_position, logo)

# 11. Calculate the position to paste the white box onto the QR code
qr_position = ((img.size[0] - white_box_size[0]) // 2, (img.size[1] - white_box_size[1]) // 2)

# 12. Paste the white box with the logo onto the QR code
img.paste(white_box, qr_position, white_box)

# 13. Save the final image
img.save(qr_code_file)

# Print success message
print(f"QR code with logo generated and saved as '{qr_code_file}'")
