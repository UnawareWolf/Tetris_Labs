# Tetris Labs Image Blocks

_Running this project requires the adacore tetris labs display framework which you probably don't have._

## What to do

Run tetris.gpr and you will see falling blocks form an image with a janky colour palette. Surprised pikachu is the default, which can be changed by putting an image in res/ and replacing the reference to surprised pikachu.png in src/scan\_image.py.

## How it works

When the ada project runs, it call a c function which runs a command line argument that runs a python script. This python script reads the image data, reduces its size and colour palette puts the output in a text file that is read by the ada program. The ada program determines how the blocks will fall. It is mostly proved with SPARK.
