#ifndef __SHAPES_H_INCLUDED__
#define __SHAPES_H_INCLUDED__

#include "../Adafruit_WS2801/Adafruit_WS2801.h"
#if (ARDUINO >= 100)
 #include <Arduino.h>
#else
 #include <WProgram.h>
 #include <pins_arduino.h>
#endif

// This class will act as a sort of 'engine' that can run background effects on the board. It is initialized as a global variable, and the effect is to be called in the loop() function.
// In most cases, the effect performed by the engine should be the first thing called in loop().
class BackgroundEngine {
	public:
	
		BackgroundEngine(Adafruit_WS2801* board);
		~BackgroundEngine(void);
		
		void
			// set the firstIt value
			setIsFirstIter(bool val),
			// set the isDone value
			setIsDone(bool val),
			// set the background colour
			setColour(uint32_t c),
			// performs the colour wipe effect. The wait is optional since 
			colourWipe(uint32_t c, uint8_t wait);
		
	private:
		// The board
		Adafruit_WS2801* strip;
		// a boolean to determine whether the given iteration the engine is running is the first.
		bool isFirstIter;
		// boolean to determine whether the effect is finished
		bool isDone;
		// We store the background explicitly
		uint32_t * background;
		// We don't know what data we need for the given effect, so we'll just have an int pointer point to another pointer containing the data we need (in most cases).
		int * data;
		
};

#endif