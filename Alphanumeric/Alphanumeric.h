#ifndef __ALPHANUMERIC_H_INCLUDED
#define __ALPHANUMERIC_H_INCLUDED

#include "../Adafruit_WS2801/Adafruit_WS2801.h"
#include "../Drawable/Drawable.h"
#include <list>
#if (ARDUINO >= 100)
 #include <Arduino.h>
#else
 #include <WProgram.h>
 #include <pins_arduino.h>
#endif

class Alphanumeric : public Drawable {

	public:
	
		// Creates a letter l from colour c, at position y, x
		Alphanumeric(Adafruit_WS2801* board, char* l, uint8_t yOff, uint8_t xOff, uint32_t c);
		// Release memory as needed
		~Alphanumeric();
		
		static int
			getBBWidth(char* l),	// Returns width of bounding box for given char
			getBBHeight(char* l);	// Returns height of bounding box for given char
			
		static Drawable**
			alphanumericString(Adafruit_WS2801* board, char* text, uint8_t yOff, uint8_t xOff, uint32_t c); //Takes in a string and returns an array of alphanumerics of each letter. yOff and xOff refer to the first letter.

};

#endif