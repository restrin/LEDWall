LEDWall
=======

Arduino/Processing sketches for LED Wall.

To start, first upload LEDStream.pde arduino file to board, so that board is ready to accept serial data from processing sketches.

Note:
  Clock pin = 11, Data pin  = 13
      
If the connection was succcessful, the board should flash red, green, blue.

Use CommunicationTemplate.pde as a starting file for processing sketches, as it will handle sending the serial data to the board.
CommunicationTemplate has a preview() method so that you can test out sketches without the board. If you are working without the board, comment out the line

  port = new Serial(this, Serial.list()[0], 115200);
  
to avoid errors.
