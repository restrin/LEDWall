#ifndef __DRAWABLE_H_INCLUDED__
#define __DRAWABLE_H_INCLUDED__

#include "../Adafruit_WS2801/Adafruit_WS2801.h"
#if (ARDUINO >= 100)
 #include <Arduino.h>
#else
 #include <WProgram.h>
 #include <pins_arduino.h>
#endif

// BIG NOTE: The grid is organized by matrix notation, so basepoint will be [y,x] not the reverse. Similarly, the functions related to the x,y position will be done using y then x.

class Drawable {

	public:

		// Create drawable object, initialize upper left corner, bounding box and also pass the strip to which it will draw
		Drawable(Adafruit_WS2801& board, uint8_t yOff, uint8_t xOff, uint8_t w, uint8_t h);
		// Release memory (as needed):
		~Drawable();
	
		void
			// Translate the drawable object to another position relative to current
			translate(int dy, int dx),
			// Set the upper left corner position of bounding box
			setPosition(uint8_t y, uint8_t x),
			// Set the colour of the drawing (affects only the non-transparent entries of bounding box array)
			setColour(uint32_t c),
			// Set the colour of a specific pixel in Drawable
			spc(uint8_t i, uint8_t j, uint32_t c),
			// Draw the drawable onto the board
			// If transparent == true, then entries with colour 0 will not be drawn to the screen (so the object will be transparent where it is not coloured), else it will overwrite.
			draw(bool transparent = true);
		uint8_t
			// Width of bounding box
			w(void),
			// Height of bounding box
			h(void),
			// Returns the x-coordinate of base point
			getBasePointX(void),
			// Returns the y-coordinate of base point
			getBasePointY(void);
		uint32_t
			// Returns pixel color in (i,j)th coordinate of bounding box array
			gpc(uint8_t i, uint8_t j);
			
	private:
			
		uint8_t 
			width,
			height,
			basePoint[2];
		Adafruit_WS2801 
			strip;
		uint32_t  
			*boundingBox;
};

#endif