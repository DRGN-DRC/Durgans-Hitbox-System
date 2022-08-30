masterListArchive.splice(overridePosition, 0, new Array ("Ganondorf",
        			 ["Down Tilt|", "", "Duration|35", "Hit|10-12", "Damage|12%", "IASA|35", ""],
        			 ["Forward Tilt|", "", "Duration|29", "Hit|9-11", "Damage|13%", ""],
        			 ["Up Tilt|", "", "Duration|114", "Hit|81-83", "Damage|27%", "IASA|113", ""],
        			 ["Down Smash|", "", "Duration|49", "Charge Frame|14", "Hit|19-22, 29-32", "Damage (charged)|8(+10)%, 16(+18)%", "IASA|47", ""],
        			 ["Forward Smash|", "", "Duration|66", "Charge Frame|10", "Hit|20-24", "Damage (charged)|22(+8)%", "IASA|60", ""],
        			 ["Up Smash|", "", "Duration|54", "Charge Frame|8", "Hit|21-23, 26-29", "Damage (charged)|22(+8)%, 17(+6)%", "IASA|40", ""],
        			 ["Back Air|", "", "Duration|35", "Hit|10-15", "Damage|16%", "IASA|29", "Auto-cancel|<img src='Parts Bin/fA.png' />&nbsp;6, 19&nbsp;<img src='Parts Bin/fA.png' class='flipIMG-x'/>", "Landing Lag|25", "L-canceled Lag|12", ""],
        			 ["Down Air|", "", "Duration|44", "Hit|16-20", "Damage|22%", "IASA|38", "Auto-cancel|<img src='Parts Bin/fA.png' />&nbsp;3, 36&nbsp;<img src='Parts Bin/fA.png' class='flipIMG-x' />", "Landing Lag|35", "L-canceled Lag|17", ""],
        			 ["Forward Air|", "", "Duration|44", "Hit|14-19", "Damage|17%", "IASA|35", "Auto-cancel|<img src='Parts Bin/fA.png' />&nbsp;6, 34&nbsp;<img src='Parts Bin/fA.png' class='flipIMG-x' />", "Landing Lag|25", "L-canceled Lag|12", ""],
        			 ["Neutral Air|", "", "Duration|44", "Hit|7-8, 16-17", "Damage|12%, 12%", "Auto-cancel|<img src='Parts Bin/fA.png' />&nbsp;3, 22&nbsp;<img src='Parts Bin/fA.png' class='flipIMG-x' />", "Landing Lag|25", "L-canceled Lag|12", ""],
        			 ["Up Air|", "", "Duration|33", "Hit|6-16", "Damage|3-13%", "Sour-spot Damage|6%", "IASA|30", "Auto-cancel|22&nbsp;<img src='Parts Bin/fA.png' class='flipIMG-x' />", "Landing Lag|25", "L-canceled Lag|12", ""],
        			 ["Down B|(grounded)", "'Wizard’s Foot'", "Duration|77", "Hit|14-34", "Damage|15%", "If the move leaves the platform, the Duration is 69. Hitting a wall adds a 60 frame animation. <br /><br />Restores mid-air jump."],
        			 ["Down B|(aerial)", "'Wizard’s Foot'", "Duration|58", "Hit|15-29", "Damage|14%", "Landing Hit|2-3", "Landing Lag|57", ""],
        			 ["Neutral B|", "'Warlock Punch'", "Duration|119", "Hit|70-72", "Damage|32%", ""],
        			 ["Side B|", "'Gerudo Dragon'", "Duration|79", "Hit Window|15-34", ""],
        			 ["Side B|(on hit)", "'Gerudo Dragon'", "Duration|25", "Hit|4-8", "Damage|17%", ""],
        			 ["Side B|(aerial)", "'Gerudo Dragon'", "Duration|79", "Hit Window|15-34", "Landing / LFS Lag|20", ""],
        			 ["Side B|(on aerial hit)", "'Gerudo Dragon'", "Duration|25", "Hit|4-8", "Landing / LFS Lag|40", ""],
        			 ["Up B|", "'Dark Dive'", "Duration|64", "Grab|13-33", "Direction Choosing|13", "Landing Lag*|30", "Edge Grabbing|45->", ""],
        			 ["Up B|(on hit)", "'Dark Dive'", "Duration|?", "Hit|3-5, 9-11, 15-17, 21-23", "Release|25", "Freefall Start|85", ""],
        			 ["Jab|", "'Thunder Punch'", "Duration|21", "Hit|3-5", "Damage|7%", "IASA|19", ""],
        			 ["Dash Attack|", "", "Duration|39", "Hit|7-16", "Damage|14%", "IASA|38", ""],
        			 ["Grab|", "", "Duration (on miss)|30", "Dashing Duration|40", "Grab|7-8", "Dash Grab|11-13", "Range|19", "Damage|3%", "Back Throw|2-9%", "Forward Throw|2-9%", "Down Throw|3-7%", "Up Throw|1-7%", "All throws have [g-type] invincibility for the first 8 frames.<br /><br />For throw speed/duration, see <a href='http://www.smashboards.com/showthread.php?t=206469' target='_blank'>here</a>."],
        			 ["Taunt|", "", "Duration|100", ""],
        			 ["Ledge Attack|(<100%)", "", "Duration|54", "Hit|24-29", "Damage|5-10%", "Invincibility|1-20", ""],
        			 ["Ledge Attack|(>100%)", "", "Duration|68", "Hit|37-40", "Damage|4-8%", "Invincibility|1-33", ""],
        			 ["Ledge Jump|(<100%)", "", "Duration|43", "Invincibility|1-11", "Soonest FF|40", ""],
        			 ["Ledge Jump|(>100%)", "", "Duration|53", "Invincibility|1-18", "Soonest FF|47", ""],
        			 ["Ledge Roll|(<100%)", "", "Duration|48", "Invincibility|1-24", "Distance|2", ""],
        			 ["Ledge Roll|(>100%)", "", "Duration|78", "Invincibility|1-54", "Distance|2", ""],
        			 ["Ledge Stand|(<100%)", "", "Duration|33", "Invincibility|1-22", ""],
        			 ["Ledge Stand|(>100%)", "", "Duration|58", "Invincibility|1-49", ""],
        			 ["Air Dodge|", "", "Duration|49", "Invincibility|4-29", ""],
        			 ["Roll|", "", "Duration|31", "Invincibility|4-19", ""],
        			 ["Spot Dodge|", "", "Duration|32", "Invincibility|2-20", ""],
        			 ["Jump|", "", "Airborne On|7", "Air Time|42", "Earliest FF|22", "FF Air Time|32", "SH Air Time|33", "SH Earliest FF|18", "SH FF Air Time|24", "2nd Jump Earliest FF|20", "Landlag|5", ""],
        			 ["Movement|", "", "Walking speed|", "Running speed|", "Dash/Run Threshold|16", "Turn-jump Threshold|16", "Run Turn-around|28", "Stopping Speed|28", ""],
        			 ["Characteristics|", "", "Shield Release Lag|16", ""]
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
		dataReconstitutor("Ganondorf", specificChar, specificMove, destination); 
}

destinationCheck();