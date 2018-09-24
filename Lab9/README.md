In this lab we design a correlation filter circuit and use it to detect the presence of a waveform.

Goal1:Your circuit has an SRAM that stores a 1-D waveform f[⋅] of 4096 data samples and a 1-D pattern
g[⋅] of 32 data samples; each sample in f[⋅] and g[⋅] is an 8-bit signed number.

When the user hit BTN0, your circuit will compute the crosscorrelation function Cfg[⋅] between f[⋅] and
g[⋅], and display the maximal value of Cfg[⋅] and its position on the 1602 LCD.
