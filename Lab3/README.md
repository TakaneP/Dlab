This time we have to synthesis on the arty board.

We have to design a circuit to display the value of a 4-bit signed counter on the LEDs with different brightness.

BTN1/BTN0 increases/decreases the counter value.
BTN2/BTN1 increases/decreases the brightness of the LEDs
(all LEDs have the same brightness simultaneously)

This lab I use the wrong way to deal with the debounce problem, if you push the button once, the LED may change twice or more.
We control the brightness using PWM signal.

P.S. The xdc file is to control the pin of the arty board and is not uploaded.
