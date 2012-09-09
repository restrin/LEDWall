#include "../Adafruit_WS2801/Adafruit_WS2801.h"
#include "Shapes.h"
#include <math.h>
/**********************************************************************************/

Shapes::Shapes(Adafruit_WS2801* board) {
	strip = board;
}

Shapes::~Shapes(void) {}

// rounds a number. >=x.5 rounds up, <x.5 rounds down.
int Shapes::round1(float n) {
	return (int) floor(n + 0.5);
}

// returns minimum of two numbers
int Shapes::min2(int n1, int n2) {
	if (n1 > n2) 
		return (float) n2;
	else
		return (float) n1;
}

// returns maximum of two numbers
int Shapes::max2(int n1, int n2) {
	if (n1 > n2) 
		return (float) n1;
	else
		return (float) n2;
}

// draws line from (x1,y1) to (x2,y2) of colour c
void Shapes::line(uint8_t i1, uint8_t j1, uint8_t i2, uint8_t j2, uint32_t c) {
	int i;
	// if its a vertical line
	if (j1 == j2) {
		for (i = min(i1, i2); i <= max(i1,i2); i++) {
			(*strip).spc(i,j1,c);
		}
	}
	else {
		// We do the following to make sure that for (a1,b1) and (a2,b2) that a1 < a2.
		// The case x1 = x2 is handled above.
		float a1 = (float) min2(j1,j2);
		float a2 = (float) max2(j1,j2);
		float b1;
		float b2;
		if (a1 == j1) {
			b1 = (float) i1;
			b2 = (float) i2;
		}
		else {
			b1 = (float) i2;
			b2 = (float) i1;
		}
		
		float m = (b2 - b1)/(a2 - a1);
		for (i = (int) a1; i <= (int) a2; i++) {
			(*strip).spc(round1(m * (i - a1) + b1), i, c);
		}
	}
}

// draws solid rectangle from corner (x1, y1) to corner (x2,y2) of colour c
void Shapes::rectangleFill(uint8_t j1, uint8_t i1, uint8_t j2, uint8_t i2, uint32_t c) {
	uint8_t a1 = min2(j1,j2);
	uint8_t a2 = max2(j1,j2);
	uint8_t b1 = min2(i1,i2);
	uint8_t b2 = max2(i1,i2);

	int i;
	//Rectangle is made by drawing vertical lines along x-axis for a1 to a2
	for (i = a1; i <= a2; i++) {
		line(b1,i,b2,i,c);
	}
}

// draws outline of rectangle, from corner (x1, y1) to corner (x2,y2) of colour c
void Shapes::rectangleOutline(uint8_t i1, uint8_t j1, uint8_t i2, uint8_t j2, uint32_t c) {
	uint8_t a1 = min2(j1,j2);
	uint8_t a2 = max2(j1,j2);
	uint8_t b1 = min2(i1,i2);
	uint8_t b2 = max2(i1,i2);
	
	//left vertical line
	line(b1,a1,b2,a1,c);
	//top horizontal line
	line(b2,a1,b2,a2,c);
	//right vertical line
	line(b2,a2,b1,a2,c);
	//bottom horizontal line
	line(b2,a2,b2,a1,c);
}

// draws a disk centered at (x,y) of radius r of colour c
disk(uint8_t i, uint8_t j, uint8_t r, uint32_t c) {
	int k;
	for (k = j-r; k <= j+r; k++) {
		// draw series of vertical lines to form disk
		line(i + round1(sqrt(pow(r,2) - pow((k-j),2))), k, i - round1(sqrt(pow(r,2) - pow((k-j),2))), k, c);
	}
}

// draws circle centered at (x,y) of radius r of colour c
void Shapes::circle(uint8_t i, uint8_t j, uint8_t r, uint32_t c) {
	int k;
	for (k = j-r; k <= j+r; k++) {
		(*strip).spc(i + round1(sqrt(pow(r,2) - pow((k-j),2))), k, c);
		(*strip).spc(i - round1(sqrt(pow(r,2) - pow((k-j),2))), k, c);
	}
}