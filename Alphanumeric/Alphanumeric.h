#ifndef __ALPHANUMERIC_H_INCLUDED
#define __ALPHANUMERIC_H_INCLUDED

#include "../Adafruit_WS2801/Adafruit_WS2801.h"
#include "../Drawable/Drawable.h"
#if (ARDUINO >= 100)
 #include <Arduino.h>
#else
 #include <WProgram.h>
 #include <pins_arduino.h>
#endif

class Alphanumeric : public Drawable {

	public:
	
		// Creates a letter l from colour c, at position y, x
		Alphanumeric(Adafruit_WS2801& board, char* l, uint8_t yOff, uint8_t xOff, uint32_t c);
		// Release memory as needed
		~Alphanumeric();
		
		static int
			getBBWidth(char* l),	// Returns width of bounding box for given char
			getBBHeight(char* l);	// Returns height of bounding box for given char

};

#endif