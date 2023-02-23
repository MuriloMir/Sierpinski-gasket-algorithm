import arsd.simpledisplay : Color, Point, ScreenPainter, SimpleWindow;
import core.thread : Fiber, Thread;
import core.time : msecs;

void main()
{
    // we start with a 800x800 pixels window and paint it black
    SimpleWindow programWindow = new SimpleWindow(800, 800, "Sierpinski Gasket");
    programWindow.draw().clear(Color.black());
    // start things in the fiber instead of a thread
    Fiber fiber = new Fiber({sierpinskiGasket(0, 0, 800, 800, programWindow);});
    // we let this event loop run lazily, the recursive function will do all the drawing
    programWindow.eventLoop(5,
    {
        // and on the timer you just call it, which picks up where it last yielded
        if (fiber.state != fiber.state.TERM)
            fiber.call();
    });
}

// this is the recursive routine, it slices the square in 4 sub squares and calls itself on the subsquares, except the lower left one
void sierpinskiGasket(int left, int top, int right, int bottom, SimpleWindow window)
{
    Fiber.yield();
    // this is the base case, when the square is 5 pixels or less in width then it just fills it with color and no further recursive calls are made
    if (right - left <= 5 || bottom - top <= 5)
    {
        ScreenPainter painter = window.draw();
        painter.outlineColor = Color.blue(), painter.fillColor = Color.blue();
        painter.drawRectangle(Point(left, top), right - left, bottom - top);
    }
    else
    {
        // we find the middle points in order to divide the square in 4 pieces
        int widthMiddle = (right - left) / 2, heightMiddle = (bottom - top) / 2;
        // we draw the one horizontal line and one vertical line, notice it is inside a scope because that is the only way the GUI gets flushed right away
        {
            ScreenPainter painter = window.draw();
            painter.outlineColor = Color.blue();
            painter.drawLine(Point(left, top + heightMiddle), Point(right, top + heightMiddle)), painter.drawLine(Point(left + widthMiddle, top), Point(left + widthMiddle, bottom));
        }
        // we calculate the positions of the sides of the each of the next 3 subsquares
        int nextLeft = left, nextTop = top, nextRight = left + widthMiddle, nextBottom = top + heightMiddle;
        // then we call the function on each of them
        sierpinskiGasket(nextLeft, nextTop, nextRight, nextBottom, window);
        nextLeft = left + widthMiddle, nextTop = top, nextRight = right, nextBottom = top + heightMiddle;
        sierpinskiGasket(nextLeft, nextTop, nextRight, nextBottom, window);
        nextLeft = left + widthMiddle, nextTop = top + heightMiddle, nextRight = right, nextBottom = bottom;
        sierpinskiGasket(nextLeft, nextTop, nextRight, nextBottom, window);
    }
}
