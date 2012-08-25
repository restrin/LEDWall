#include "../Adafruit_WS2801/Adafruit_WS2801.h"
#include "Drawable.h"
#include <stdlib.h>

/**********************************************************************************/

// Constructor with colour
Drawable::Drawable(Adafruit_WS2801* board, uint8_t yOff, uint8_t xOff, uint8_t w, uint8_t h) {
	strip = board;
	basePoint[0] = yOff;
	basePoint[1] = xOff;
	width = w;
	height = h;
	boundingBox = (uint32_t*) calloc(w * h, 4); // later I will figure out how to properly dynamically allocate/deallocate memory for multidimensional arrays
}

Drawable::~Drawable(void) {
	free(boundingBox);
}

// Width of bounding box
uint8_t Drawable::w(void) {
	return width;
}

// Height of bounding box
uint8_t Drawable::h(void) {
	return height;
}

// Translate the drawable object to another position relative to current
void Drawable::translate(int dy, int dx) {
	basePoint[0] += dy;
	basePoint[1] += dx;
}

// Set the upper left corner position of bounding box
void Drawable::setPosition(uint8_t y, uint8_t x) {
	basePoint[0] = y;
	basePoint[1] = x;
}

// Set the colour of the drawing (affects only the non-transparent entries of bounding box array)
void Drawable::setColour(uint32_t c) {
	int i;
	for (i = 0; i < w() * h(); i++) {
		if (boundingBox[i] != 0) {
			boundingBox[i] = c;
		}
	}
}
// Set the colour of a specific pixel in Drawable. Must be valid pixel, else will do nothing.
void Drawable::spc(uint8_t i, uint8_t j, uint32_t c) {
	if ( i < h() && i >= 0 && j < w() && j >= 0 ) {
		boundingBox[i * w() + j] = c;
	}
}
// Draw the drawable onto the board
// If transparent = true, then entries with colour 0 will not be drawn to the screen (so the object will be transparent where it is not coloured), else it will overwrite.
void Drawable::draw(bool transparent) {
	int i,j;
	
	for (i = 0; i < h(); i++) {
		for (j = 0; j < w(); j++) {
			if (!transparent || boundingBox[i * w() + j] > 0) 
				(*strip).spc(i + basePoint[0],j + basePoint[1], boundingBox[i * w() + j]); // Remember, we are using matrix subscript notation, so yOff first, then xOff
		}
	}
}

// Returns the base point x-coordinate
uint8_t Drawable::getBasePointX(void) {
	return basePoint[1];
}

// REturns the base point y-coordinate
uint8_t Drawable::getBasePointY(void) {
	return basePoint[0];
}

// Returns pixel color in (i,j)th coordinate of bounding box array
uint32_t Drawable::gpc(uint8_t i, uint8_t j) {
	return boundingBox[i * w() + j];
}

// Causes drawables to crawl across screen. Delay is in milliseconds.
// NOTE: To work properly, board cannot already have any of the letters to be crawled drawn on it yet.
//		 Every iteration it will redraw the 'original' board, and then draw the drawables being crawled.
void Drawable::crawl(Adafruit_WS2801* board, Drawable** d, int dlen, int dy, int dx, int n, int wait) {
	int i,j,k,l;
	
	uint32_t* background = (uint32_t*) calloc((*board).h() * (*board).w(), 4);
	
	for (i = 0; i < (*board).h(); i++) {
		for (j = 0; j < (*board).w(); j++) {
			background[i*(*board).w() + j] = (*board).gpc(i,j);
		}
	}

	for (i = 0; i < n; i++) {
		for (k = 0; k < (*board).h(); k++) {
			for (l = 0; l < (*board).w(); l++) {
				(*board).spc(k,l,background[k*(*board).w() + l]);
			}
		}
		for (j = 0; j < dlen; j++) {
			(*d[j]).draw();
			(*d[j]).translate(dy, dx);
		}
		(*board).show();
		delay(wait);
	}
	
	free(background);
}