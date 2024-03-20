# Durgans-Hitbox-System
 App + PNG images for displaying hitbox and frame data for SSBM.

This is a very old project of mine (one of my first forays into Melee hacking), inspired by an old frames project called Seanson's Hitbox System. This is just a skeletal outline of my files on this project, and not everything here is complete.

One of the big differences between this and other frame-viewing projects is that this sets up the camera in exactly the same position relative to the character for every shot. This makes hitboxes between different moves as well as between different characters all to the same scale, and therefore directly comparable to each other. This fact is taken advantage of with the 'Comparison Mode' feature. By clicking on that button at the bottom of the app, you can bring up two different moves from different characters (each with their own sets of controls), then drag them to position and/or overlap them, so you can look at how different interactions might work.

![Demo Image](/Parts%20Bin/demo.png)

The app supports frame-by-frame advance forward or backward, playback at various speeds (anywhere between 2x and 1/64th speed), scrubbing (in a timeline bar which displays position in time for hitboxes, reflect boxes, invincibility, etc.), displays move info/stats, and more. 

This repo also contains the beginnings of a framework for automatically capturing screenshots to make the frames. You can find this in the "Frame Creation" folder.
