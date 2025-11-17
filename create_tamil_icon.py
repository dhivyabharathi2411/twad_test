#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
TWAD App Icon Generator with Tamil Text
Creates a 512x512 app icon with Tamil text included
"""

try:
    from PIL import Image, ImageDraw, ImageFont
    import os
    
    def create_twad_icon():
        # Create a 512x512 image with blue background
        size = 512
        img = Image.new('RGBA', (size, size), (21, 101, 192, 255))  # TWAD Blue
        
        # Create a circular mask for rounded corners
        mask = Image.new('L', (size, size), 0)
        mask_draw = ImageDraw.Draw(mask)
        mask_draw.ellipse([40, 40, size-40, size-40], fill=255)
        
        # Create inner white circle
        draw = ImageDraw.Draw(img)
        draw.ellipse([56, 56, size-56, size-56], fill=(255, 255, 255, 255))
        
        # Try to load a font that supports Tamil
        try:
            # Try different font paths for Tamil support
            tamil_font = ImageFont.truetype("/System/Library/Fonts/Arial Unicode MS.ttf", 36)
            english_font = ImageFont.truetype("/System/Library/Fonts/Arial Bold.ttf", 48)
            sub_font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", 24)
        except:
            # Fallback to default font
            tamil_font = ImageFont.load_default()
            english_font = ImageFont.load_default()
            sub_font = ImageFont.load_default()
        
        # Draw Tamil text
        tamil_text = "தமிழ்நாடு\nகுடிநீர் வடிகால்\nவாரியம்"
        draw.multiline_text((size//2, 150), tamil_text, fill=(21, 101, 192), 
                           font=tamil_font, anchor="mm", align="center")
        
        # Draw English text
        draw.text((size//2, 280), "TWAD", fill=(21, 101, 192), 
                 font=english_font, anchor="mm")
        
        draw.text((size//2, 320), "Water Board", fill=(25, 118, 210), 
                 font=sub_font, anchor="mm")
        
        # Draw water drop
        draw.ellipse([240, 350, 260, 380], fill=(33, 150, 243))
        draw.polygon([(250, 340), (245, 355), (255, 355)], fill=(33, 150, 243))
        
        # Apply the mask for rounded corners
        img.putalpha(mask)
        
        return img
    
    # Create the icon
    icon = create_twad_icon()
    
    # Save the icon
    output_path = "assets/images/twad_logo_tamil.png"
    icon.save(output_path)
    
except ImportError:
    print("❌ PIL (Pillow) not installed")
    print("Install with: pip install Pillow")
except Exception as e:
    print(f"❌ Error creating icon: {e}")
    print("💡 Use the HTML method instead - open twad_icon_with_tamil.html in browser")
