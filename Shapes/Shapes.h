#ifndef __SHAPES_H_INCLUDED__
#define __SHAPES_H_INCLUDED__

#include "../Adafruit_WS2801/Adafruit_WS2801.h"
#if (ARDUINO >= 100)
 #include <Arduino.h>
#else
 #include <WProgram.h>
 #include <pins_arduino.h>
#endif

// A class (essentially a library) that draws various shapes to the screen. Unlike Drawable, it will not store the shapes in memory, so they cannot be called on after they are drawn.
// We are using matrix notation, so its not x,y coordinates, by i,j indices.
class Shapes {
	
	public:
		
		// Constructor. Just takes in the board so that it knows where to draw to.
		Shapes(Adafruit_WS2801* board);
		~Shapes(void);
		
		void
			// draws line from (i1,j1) to (i2,j2) of colour c
			line(uint8_t i1, uint8_t j1, uint8_t i2, uint8_t j2, uint32_t c),
			// draws solid rectangle, defined corner (i1,j1) to corner (i2,j2) of colour c
			rectangleFill(uint8_t i1, uint8_t j1, uint8_t i2, uint8_t j2, uint32_t c),
			// draws outline of rectangle, defined corner (i1,j1) to corner (i2,j2) of colour c
			rectangleOutline(uint8_t i1, uint8_t j1, uint8_t i2, uint8_t j2, uint32_t c),
			// draws a disk centered at (x,y) and with radius r of colour c
			disk(uint8_t i, uint8_t j, uint8_t r, uint32_t c),
			// draws circle centered at (x,y) and with radius r of colour c
			circle(uint8_t i, uint8_t j, uint8_t r, uint32_t c);
			
	private:
		// The following functions have weird names to avoid name clashes
		int
			// rounds a number
			round1(float n),
			// returns minimum of two numbers
			min2(int n1, int n2),
			// returns maximum of two numbers
			max2(int n1, int n2);
			
		Adafruit_WS2801* strip;
		
};

#endif