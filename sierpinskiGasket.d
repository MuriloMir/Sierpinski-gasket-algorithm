// This software draws a Sierpinski gasket recursively using the fiber feature of Dlang.

import arsd.simpledisplay : Color, Point, ScreenPainter, SimpleWindow;
import core.thread : Fiber;

// this is the recursive function, it slices the father square into 4 child squares and calls itself on the child squares, except the lower left one
void sierpinskiGasket(int left, int top, int right, int bottom, SimpleWindow window)
{
    // stop the fiber and wait until it is called again
    Fiber.yield();

    // if the square is smaller than or equal to 5 pixels
    if (right - left <= 5 || bottom - top <= 5)
    {
        // create the painter
        ScreenPainter painter = window.draw();

        // get the color blue for the outline and the fill
        painter.outlineColor = Color.blue(), painter.fillColor = Color.blue();
        // just fill the square, this is the base case
        painter.drawRectangle(Point(left, top), right - left, bottom - top);
    }
    // if the square is bigger than 5 pixels
    else
    {
        // find the midpoints in order to divide the square into 4 pieces
        int widthMiddle = (right - left) / 2, heightMiddle = (bottom - top) / 2;

        // draw the lines to divide it, notice it's inside a scope so that the GUI gets flushed right away
        {
            // create the painter
            ScreenPainter painter = window.draw();

            // get the blue color
            painter.outlineColor = Color.blue();
            // draw the horizontal line
            painter.drawLine(Point(left, top + heightMiddle), Point(right, top + heightMiddle));
            // draw the vertical line
            painter.drawLine(Point(left + widthMiddle, top), Point(left + widthMiddle, bottom));
        }

        // calculate the coordinates of the sides of the 1st child square
        int nextLeft = left, nextTop = top, nextRight = left + widthMiddle, nextBottom = top + heightMiddle;

        // call the function on it, recursively
        sierpinskiGasket(nextLeft, nextTop, nextRight, nextBottom, window);

        // calculate the coordinates of the sides of the 2nd child square
        nextLeft = left + widthMiddle, nextTop = top, nextRight = right, nextBottom = top + heightMiddle;

        // call the function on it, recursively
        sierpinskiGasket(nextLeft, nextTop, nextRight, nextBottom, window);

        // calculate the coordinates of the sides of the 3rd child square
        nextLeft = left + widthMiddle, nextTop = top + heightMiddle, nextRight = right, nextBottom = bottom;

        // call the function on it, recursively
        sierpinskiGasket(nextLeft, nextTop, nextRight, nextBottom, window);
    }
}

// start the software
void main()
{
    // create the window for the GUI
    SimpleWindow programWindow = new SimpleWindow(800, 800, "Sierpinski Gasket");

    // clear the GUI, it's in a scope so the GUI gets flushed right away
    {programWindow.draw().clear(Color.black());}

    // create the fiber and call the recursive function which draws the gasket
    Fiber fiber = new Fiber({sierpinskiGasket(0, 0, 800, 800, programWindow);});

    // start the event loop
    programWindow.eventLoop(5,
    {
        // if the fiber hasn't finished yet
        if (fiber.state != fiber.state.TERM)
            // call the fiber again, to resume the work
            fiber.call();
    });
}
