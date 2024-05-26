# Example Projects (LÖVE)
A few old projects made for the LÖVE2D framework.

These will require an installation of the [LÖVE2D](https://love2d.org/) framework to run, located at `C://LOVE`.

There are various batch files in each project, which were used as a simple build toolkit.
In general, `compile.bat` packs the code (using 7-Zip) into a `*.love` file, and `run.bat` runs the file.

The batch files may not all be consistent with the expected path of Love2D and 7-Zip; the process is easy to glean from the scripts, so fixes should be easy if there is an issue.

All of these programs can be closed by pressing the Escape key.
(The framework is designed to hard-fail from uncaught exceptions, so given the unpolished nature of these programs, you may run into some crashes.)<hr>

#### Civilization
A incomplete game made in the style of Civilization 5.

Left Click - Select Units.<br>
Right Click - Move. Hold to show path.<br>
Shift + Left Click - Show Tile Information<br>

<img src="https://github.com/mlasala45/example-projects-love/assets/118553159/e4b65188-bfa9-4a47-8c6b-7afe34c11314" width="49%">
<img src="https://github.com/mlasala45/example-projects-love/assets/118553159/773983c8-e9cf-4a43-b0ec-606b1ef97b84" width="49%">
<img src="https://github.com/mlasala45/example-projects-love/assets/118553159/04b8b8f7-5503-493b-827d-698435ee5366" width="49%">
<img src="https://github.com/mlasala45/example-projects-love/assets/118553159/dd18386d-153c-44a7-9aab-32f404d65d89" width="49%"><hr>

#### MSE-TTS Network Interface
A tool for presenting MSE card set exports to a Tabletop Simulator importer script, using a local server.

MSE is a program for designing custom Magic: The Gathering cards. This tool uses a slightly modified version of an importer script, which collects data for a MTG deck and spawns objects to represent it into Tabletop Simulator. The script exclusively downloads information from a remote source, so this tool reformats the exports from MSE and presents them on a local server that the importer can access.

See INSTRUCTIONS.txt for operating instructions.<hr>

#### Hacking
A simple UI proof-of-concept for a hacking game. Mousing over a node plays an animation, and displays an IP address.

<img src="https://github.com/mlasala45/example-projects-love/assets/118553159/b302b6c0-2947-4120-984b-70597f8665ac" width="49%"><hr>


#### Coastline Gen v2 - Voronoi
One of a series of experiments with procedural generation. A Voronoi graph is generated, and cells are marked as inside or outside of the island using a hardcoded formula.

R - Reset the simulation.<br>
Space - Pause and unpause.<br>
G - Toggle Grayscale/Color<br>
W - Toggle Single Shade<br>

<img src="https://github.com/mlasala45/example-projects-love/assets/118553159/2034e943-03d4-4dff-848c-657b0555e66c" width="49%">
<img src="https://github.com/mlasala45/example-projects-love/assets/118553159/29a7a17d-fe27-4885-9b94-5946a93740fa" width="49%">
<img src="https://github.com/mlasala45/example-projects-love/assets/118553159/ac477df5-ea31-4613-89c3-1165017409d4" width="49%">
