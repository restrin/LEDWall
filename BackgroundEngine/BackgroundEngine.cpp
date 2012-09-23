#include "../Adafruit_WS2801/Adafruit_WS2801.h"
#include "BackgroundEngine.h"

/**********************************************************************************/

BackgroundEngine::BackgroundEngine(Adafruit_WS2801* board) {
	strip = board;
	isFirstIter = true;
	isDone = false;
	// NOTE: We will not allocate the background member here, since there are effects where we can avoid this and save memory. Thus allocation for background will be done in the specific effect.
}

BackgroundEngine::~BackgroundEngine() {
	free(background);
	free(data);
}

void BackgroundEngine::setIsFirstIter(bool val) {
	isFirstIter = val;
}

void BackgroundEngine::setIsDone(bool val) {
	isDone = val;
	free(data);
	data = NULL;
}

// Performs colourwipe. wait is in milliseconds.
void BackgroundEngine::colourWipe(uint32_t c, uint8_t wait) {
	if (!isDone) {
		if (isFirstIter) {
			// To perform a colourWipe iteration, we need to store the current LED we need to colour. Since all we need to store for this effect is one int, we'll store it in data without any memory allocation.
			*data = 0;
		}
		setIsFirstIter(false);
		int i;
		for (i = 0; i < *data; i++) {
			(*strip).spc(*data / (*strip).w(), *data % (*strip).w(), c);
		}
		
		*data++;
		
		// We don't need to continue after we've done every pixel.
		if (*data == ((*strip).w() * (*strip).h())) {
			setIsDone(true);
		}
		
		delay(wait);
	}
}