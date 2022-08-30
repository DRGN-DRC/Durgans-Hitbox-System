masterListArchive.splice(overridePosition, 0, new Array ("Zelda",
        			 ["Down Tilt|", "", "Duration|", "Hit|", "Damage|%", "IASA|", ""],
        			 ["Forward Tilt|", "", "Duration|", "Hit|", "Damage|%", ""],
        			 ["Up Tilt|", "", "Duration|", "Hit|", "Damage|%", "IASA|", ""],
        			 ["Down Smash|", "", "Duration|", "Charge Frame|", "Hit|", "Damage (charged)|(+)%", "IASA|", ""],
        			 ["Forward Smash|", "", "Duration|", "Charge Frame|", "Hit|", "Damage (charged)|(+)%", "IASA|", ""],
        			 ["Up Smash|", "", "Duration|", "Charge Frame|", "Hit|", "Damage (charged)|(+)%, (+)%", "IASA|", ""],
        			 ["Back Air|", "", "Duration|", "Hit|", "Damage|%", "IASA|", "Auto-cancel|<img src='Parts Bin/fA.png' />&nbsp;, &nbsp;<img src='Parts Bin/fA.png' class='flipIMG-x'/>", "Landing Lag|", "L-canceled Lag|", ""],
        			 ["Down Air|", "", "Duration|", "Hit|", "Damage|%", "IASA|", "Auto-cancel|<img src='Parts Bin/fA.png' />&nbsp;, &nbsp;<img src='Parts Bin/fA.png' class='flipIMG-x' />", "Landing Lag|", "L-canceled Lag|", ""],
        			 ["Forward Air|", "'Lightning Kick'", "Duration|39", "Hit|8-11", "Damage|20%", "IASA|36", "Auto-cancel|<img src='Parts Bin/fA.png' />&nbsp;7, 25&nbsp;<img src='Parts Bin/fA.png' class='flipIMG-x' />", "Landing Lag|18", "L-canceled Lag|9", ""],
        			 ["Neutral Air|", "", "Duration|", "Hit|", "Damage|%", "IASA|", "Auto-cancel|<img src='Parts Bin/fA.png' />&nbsp;, &nbsp;<img src='Parts Bin/fA.png' class='flipIMG-x' />", "Landing Lag|", "L-canceled Lag|", ""],
        			 ["Up Air|", "", "Duration|", "Hit|", "Damage|%", "Sour-spot Damage|%", "IASA|", "Auto-cancel|<img src='Parts Bin/fA.png' />&nbsp;, &nbsp;<img src='Parts Bin/fA.png' class='flipIMG-x' />", "Landing Lag|", "L-canceled Lag|", ""],
        			 ["Down B|", "", "Duration|", "Hit|", "Damage|%", ""],
        			 ["Neutral B|", "'Warlock Punch'", "Duration|", "Hit|", "Damage|%", ""],
        			 ["Side B|", "", "Duration|", "Hit Window|", ""],
        			 ["Side B|(on hit)", "", "Duration|", "Hit|", "Damage|%", ""],
        			 ["Side B|(aerial)", "", "Duration|", "Hit Window|", "Landing / LFS Lag|", ""],
        			 ["Side B|(on aerial hit)", "", "Duration|", "Hit|", "Landing / LFS Lag|", ""],
        			 ["Up B|", "", "Duration|", "Grab|", "Direction Choosing|13", "Landing Lag*|", "Edge Grabbing|&nbsp;<img src='Parts Bin/fA.png' class='flipIMG-x' />", ""],
        			 ["Up B|(on hit)", "", "Duration|", "Hit|", "Freefall Start|", ""],
        			 ["Jab|", "", "Duration|", "Hit|", "Damage|%", "IASA|", ""],
        			 ["Dash Attack|", "", "Duration|37", "Hit|6-13", "Damage|12%", "Sour-spot Damage|8%", "IASA|36", ""],
        			 ["Grab|", "", "Duration (on miss)|", "Dashing Duration|", "Grab|", "Dash Grab|", "Range|", "Damage|%", "Back Throw|%", "Forward Throw|%", "Down Throw|%", "Up Throw|%", "All throws have [g-type] invincibility for the first 8 frames.<br /><br />For throw speed/duration, see <a href='http://www.smashboards.com/showthread.php?t=206469' target='_blank'>here</a>."],
        			 ["Taunt|", "", "Duration|", ""],
        			 ["Ledge Attack|(<100%)", "", "Duration|", "Hit|", "Damage|%", "Invincibility|", ""],
        			 ["Ledge Attack|(>100%)", "", "Duration|", "Hit|", "Damage|%", "Invincibility|", ""],
        			 ["Ledge Jump|(<100%)", "", "Duration|", "Invincibility|", "Soonest FF|", ""],
        			 ["Ledge Jump|(>100%)", "", "Duration|", "Invincibility|", "Soonest FF|", ""],
        			 ["Ledge Roll|(<100%)", "", "Duration|", "Invincibility|", "Distance|", ""],
        			 ["Ledge Roll|(>100%)", "", "Duration|", "Invincibility|", "Distance|", ""],
        			 ["Ledge Stand|(<100%)", "", "Duration|", "Invincibility|", ""],
        			 ["Ledge Stand|(>100%)", "", "Duration|", "Invincibility|", ""],
        			 ["Air Dodge|", "", "Duration|", "Invincibility|", ""],
        			 ["Roll|", "", "Duration|", "Invincibility|", ""],
        			 ["Spot Dodge|", "", "Duration|", "Invincibility|", ""],
        			 ["Jump|", "", "Airborne On|", "Air Time|", "Earliest FF|", "FF Air Time|", "SH Air Time|", "SH Earliest FF|", "SH FF Air Time|", "2nd Jump Earliest FF|", "Landlag|", ""],
        			 ["Movement|", "", "Walking speed|", "Running speed|", "Dash/Run Threshold|", "Turn-jump Threshold|", "Run Turn-around|", "Stopping Speed|", ""],
        			 ["Characteristics|", "", "Shield Release Lag|", ""]
					 )); // ^ Make sure there's no comma for last array only.

function destinationCheck() { // The variable "destinationLock" is a flag for which character/move pair to look at and where to display the data. (Set by the appendData function.)
		var destination = destinationLock;
		switch (destinationLock) {
				case '#data1':
						specificChar = chosenChar1
						specificMove = chosenMove1
						break;
				case '#data2':
						specificChar = chosenChar2
						specificMove = chosenMove2
						break;
		}
		destinationLock = "open"
		dataReconstitutor("Zelda", specificChar, specificMove, destination); 
}

destinationCheck();