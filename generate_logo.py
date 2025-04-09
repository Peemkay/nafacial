import os
from PIL import Image, ImageDraw, ImageFont
import cairosvg

def generate_logo():
    # Create a circular background
    size = 512
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    
    # Draw the circular background
    center = size // 2
    radius = size // 2 - 10
    draw.ellipse((center - radius, center - radius, center + radius, center + radius), fill=(0, 31, 63, 255))
    
    # Draw the shield outline
    shield_width = size * 0.6
    shield_height = size * 0.7
    shield_top = center - shield_height // 2
    shield_left = center - shield_width // 2
    
    # Draw the shield (simplified)
    points = [
        (center, shield_top),  # Top center
        (shield_left + shield_width, shield_top + shield_height * 0.2),  # Right shoulder
        (shield_left + shield_width, shield_top + shield_height * 0.6),  # Right waist
        (center, shield_top + shield_height),  # Bottom center
        (shield_left, shield_top + shield_height * 0.6),  # Left waist
        (shield_left, shield_top + shield_height * 0.2),  # Left shoulder
    ]
    draw.polygon(points, outline=(255, 215, 0, 255), width=5)
    
    # Draw a face circle in the center
    face_radius = size * 0.15
    draw.ellipse((center - face_radius, center - face_radius, center + face_radius, center + face_radius), 
                 outline=(255, 215, 0, 255), width=3)
    
    # Draw eyes
    eye_radius = size * 0.03
    left_eye_center = (center - face_radius * 0.5, center - face_radius * 0.2)
    right_eye_center = (center + face_radius * 0.5, center - face_radius * 0.2)
    
    draw.ellipse((left_eye_center[0] - eye_radius, left_eye_center[1] - eye_radius, 
                  left_eye_center[0] + eye_radius, left_eye_center[1] + eye_radius), 
                 fill=(255, 215, 0, 255))
    
    draw.ellipse((right_eye_center[0] - eye_radius, right_eye_center[1] - eye_radius, 
                  right_eye_center[0] + eye_radius, right_eye_center[1] + eye_radius), 
                 fill=(255, 215, 0, 255))
    
    # Draw scanning line
    scan_width = face_radius * 2
    scan_height = size * 0.01
    draw.rectangle((center - scan_width / 2, center + face_radius * 0.3, 
                   center + scan_width / 2, center + face_radius * 0.3 + scan_height), 
                  fill=(255, 215, 0, 255))
    
    # Add text "NAFacial"
    try:
        # Try to load a font, fall back to default if not available
        font = ImageFont.truetype("arial.ttf", size=int(size * 0.08))
    except IOError:
        font = ImageFont.load_default()
    
    text = "NAFacial"
    text_width = draw.textlength(text, font=font)
    draw.text((center - text_width / 2, center + face_radius * 1.5), text, 
              fill=(255, 215, 0, 255), font=font)
    
    # Save the image
    os.makedirs('assets/favicon', exist_ok=True)
    image_path = 'assets/favicon/nafacial_logo.png'
    image.save(image_path)
    
    # Create smaller versions for different platforms
    sizes = [192, 96, 48, 32]
    for size in sizes:
        resized = image.resize((size, size), Image.LANCZOS)
        resized.save(f'assets/favicon/nafacial_logo_{size}x{size}.png')
    
    print(f"Logo generated and saved to {image_path}")
    return image_path

def convert_svg_to_png():
    """Convert the existing SVG logo to PNG if it exists"""
    svg_path = 'assets/favicon/nafacial_logo.svg'
    if os.path.exists(svg_path):
        png_path = 'assets/favicon/nafacial_logo.png'
        cairosvg.svg2png(url=svg_path, write_to=png_path, output_width=512, output_height=512)
        print(f"Converted SVG to PNG: {png_path}")
        return png_path
    return None

if __name__ == "__main__":
    try:
        # First try to convert existing SVG
        png_path = convert_svg_to_png()
        if not png_path:
            # If no SVG or conversion failed, generate from scratch
            png_path = generate_logo()
        
        print(f"Logo saved to {png_path}")
    except Exception as e:
        print(f"Error generating logo: {e}")
        # Generate a simple fallback logo if everything else fails
        generate_logo()
