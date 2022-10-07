# Written by Daniel Cappel (DRGN)
# Version .2
#
# This script is designed to create images for hitbox visualization; 
# initially designed for the DHS. Finished frames should have no elements 
# in them besides a character and their hitboxes (hidden stage, hud, etc.), 
# and features transparent backgrounds for use in overlays. 
#
# This process uses Slippi-Dolphin and libmelee to collect screenshots, 
# and then GIMP to post-process the frames, to crop and remove the background. 
#
# Command-line arguments:
#
#		todo if anyone wants this
#
# Potential exit codes:
#
# 		0: Success; all frames created with no problems
# 		1: Invalid set-up; one or more dependencies not found
# 		2: Aborted by user (CTRL-C)
# 		3: Unable to connect to console
# 		4: Unable to connect controllers
#		5: No characters or moves selected for collection!
#		6: Dolphin could not be started (startup timed out)

import os
import sys
import csv
import time
import errno
import psutil
import shutil
import signal
import win32gui
import subprocess
import win32process

from enum import Enum
from PIL import ImageGrab

# Ensure libmelee is installed and can be loaded
try:
	import melee
	from melee import Action, Button, Character
	print( 'Successfully loaded libmelee library (' + str(melee.version.__version__) + ').' )
except:
	print( 'Unable to load the libmelee Python library; be sure to follow setup in "Set-up and workflow.txt" to get started.' )
	sys.exit( 1 )


dolphinExePath = "D:\Games\- Emulators -\Dolphin\FM-Slippi-2.5.1-Win-DHS\Slippi Dolphin.exe"
discPath = "D:\Projects\DHS\Super Smash Bros. Melee (NTSC v1.02).iso"

recordingEnabled = True 			# Turn this off to disable capturing screenshots (will just do a dry run through moves)
postProcessingEnabled = False		# Crop frames and remove background
skipCollectedFrames = False			# If frames have already been collected for a move, skip it rather than redoing it
frameCountFallback = 80				# If unable to determine a move's framecount, use this instead (overridden by some moves)
debugging = True

collectAllCharacters = False 		# Will override the character selections below
collectAllMoves = False 			# Will override the move selections below

charsToCollect = { # Key = CSS ID/appearance
    0x00: False, 	# DOC
    0x01: True, 	# MARIO
    0x02: False, 	# LUIGI
    0x03: False, 	# BOWSER
    0x04: False, 	# PEACH
    0x05: False, 	# YOSHI
    0x06: False, 	# DK
    0x07: False, 	# CPTFALCON
    0x08: False, 	# GANONDORF
    0x09: False, 	# FALCO
    0x0a: False, 	# FOX
    0x0b: False, 	# NESS
    0x0c: False, 	# POPO
    0x0d: False, 	# KIRBY
    0x0e: False, 	# SAMUS
    0x0f: False, 	# ZELDA
    0x10: True, 	# LINK
    0x11: False, 	# YLINK
    0x12: False, 	# PICHU
    0x13: False, 	# PIKACHU
    0x14: False, 	# JIGGLYPUFF
    0x15: False, 	# MEWTWO
    0x16: False, 	# GAMEANDWATCH
    0x17: False, 	# MARTH
    0x18: False, 	# ROY
}

class Move( str, Enum ):

	label: str
	enabled: bool

	""" The True/False values below determine whether 
		that move is enabled and should be collected. """

	DASH_ATTACK 		= ( 'dash attack', False )			# Index 1
	DASH_GRAB 			= ( 'dash grab', False )
	DOWN_B_GROUND 		= ( 'down b (grounded)', False )
	DOWN_SMASH 			= ( 'down smash', False )
	DOWN_TILT 			= ( 'down tilt', False )
	FORWARD_SMASH 		= ( 'forward smash', False )
	FORWARD_TILT 		= ( 'forward tilt', True )
	GETUP_ATTACK_FRONT 	= ( 'get-up attack (front)', False )
	GETUP_ATTACK_BACK 	= ( 'get-up attack (back)', False )
	GRAB 				= ( 'grab', False )					# Index 10
	JAB_1 				= ( 'jab', False )
	JAB_2 				= ( 'jab 2', False )
	JAB_3 				= ( 'jab 3', True )
	JAB_RAPID 			= ( 'rapid jab', False )
	LEDGE_ATTACK_LOW 	= ( 'ledge attack (< 100%)', False )
	LEDGE_ATTACK_HIGH 	= ( 'ledge attack (>= 100%)', False )
	NEUTRAL_B_GROUND 	= ( 'neutral b (grounded)', False )
	ROLL_FORWARD 		= ( 'roll (forward)', False )
	ROLL_BACK 			= ( 'roll (back)', False )
	SIDE_B_GROUND 		= ( 'side b (grounded)', False )	# Index 20
	SPOT_DODGE 			= ( 'spot dodge', False )
	UP_B_GROUND 		= ( 'up b (grounded)', False )
	UP_SMASH 			= ( 'up smash', False )
	UP_TILT 			= ( 'up tilt', False )

	# Air based
	AIR_DODGE 			= ( 'air dodge', False )			# Index 25
	BACK_AIR 			= ( 'back air', False )
	DOWN_AIR 			= ( 'down air', False )
	DOWN_B_AIR 			= ( 'down b (aerial)', False )
	FORWARD_AIR 		= ( 'forward air', False )
	NEUTRAL_AIR 		= ( 'neutral air', False )			# Index 30
	NEUTRAL_B_AIR 		= ( 'neutral b (aerial)', False )
	SIDE_B_AIR 			= ( 'side b (aerial)', False )
	UP_AIR 				= ( 'up air', False )
	UP_B_AIR 			= ( 'up b (aerial)', False )
	
	def __new__( cls, label: str = "", enabled: bool = False ):

		""" This method allows this enum to basically have 3 values. 
			The first is the index as normal, so enums can still be 
			accessed by index (e.g. Move(1) for Move.DASH_ATTACK). 
			The second two values can be accessed via Move(1).label 
			or Move(1).enabled. 
			
			Source:
			https://rednafi.github.io/reflections/add-additional-attributes-to-enum-members-in-python.html
			
			"""

		index = len( cls ) + 1

		obj = str.__new__( cls, index )
		obj._value_ = index

		obj.label = label
		obj.enabled = enabled
		
		return obj

charNames = [ # Indexed by CSS ID/appearance
	"Doc",				# 0x0
	"Mario",
	"Luigi",
	"Bowser",
	"Peach",
	"Yoshi",
	"DK",
	"Captain Falcon",
	"Ganondorf",		# 0x8
	"Falco",
	"Fox",
	"Ness",
	"Ice Climbers",
	"Kirby",
	"Samus",
	"Zelda",
	"Link",				# 0x10
	"Young Link",
	"Pichu",
	"Pikachu",
	"Jigglypuff",
	"Mewtwo",
	"Game & Watch",
	"Marth",
	"Roy"				# 0x18

	# "Solo Popo",
	# "Sheik",
	# "Master Hand",
	# "Male Wireframe",
	# "Female Wireframe",
	# "Giga Bowser",
	# "Crazy Hand",
	# "Sandbag",
]


hasJab2 = [ 'Doc', 'Mario', 'Luigi', 'Bowser', 'Peach', 'Yoshi', 'DK', 
			'Captain Falcon', 'Falco', 'Fox', 'Ness', 'Ice Climbers',
			'Kirby', 'Samus', 'Link', 'Young Link', 'Jigglypuff', 'Marth' ]
hasJab3 = [ 'Doc', 'Mario', 'Luigi', 'Captain Falcon', 'Ness', 'Link', 'Young Link' ]
hasJabRapid = [ 'Captain Falcon', 'Falco', 'Fox', 'Kirby', 'Link', 'Young Link', 'Mewtwo', 'Game & Watch' ]


def cmdChannel( command, standardInput=None, shell=False, returnStderrOnSuccess=False ):
	
	""" IPC (Inter-Process Communication) to command line. Blocks; i.e will not return until the 
		process is complete. shell=True gives access to all shell features/commands, such dir or copy. 
		creationFlags=0x08000000 prevents creation of a console for the process. 
		Returns ( returnCode, stdoutData ) if successful, else ( returnCode, stderrData ). """

	try:
		process = subprocess.Popen( command, shell=shell, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, creationflags=0x08000000, text=True )
		stdoutData, stderrData = process.communicate( input=standardInput )
	except Exception as err:
		return ( -1, 'The subprocess command failed; ' + str(err) )

	if process.returncode == 0 and returnStderrOnSuccess:
		return ( process.returncode, stderrData )
	elif process.returncode == 0:
		return ( process.returncode, stdoutData )
	else:
		print( 'IPC error (exit code {}):'.format( process.returncode ) )
		print( stderrData )
		return ( process.returncode, stderrData )


def createFolders( folderPath ):
	try:
		os.makedirs( folderPath )

		# Primitive failsafe to prevent race condition
		attempt = 0
		while not os.path.exists( folderPath ):
			time.sleep( .3 )
			if attempt > 10:
				raise Exception( 'Unable to create folder: ' + folderPath )
			attempt += 1

	except OSError as error: # Python >2.5
		if error.errno == errno.EEXIST and os.path.isdir( folderPath ):
			pass
		else: raise


class CustomLogger( melee.Logger ):

	def __init__( self ):
		super().__init__()

		fieldnames = [ 'Frame', 'Character', 'Target Move', 'P1 x', 'P1 y', 'P1 Action', 'P1 Action Frame', 
						'Buttons Pressed', 'Notes', 'Frame Process Time' ]
		self.writer = csv.DictWriter(self.csvfile, fieldnames=fieldnames, extrasaction='ignore')
	
	def logframe( self, gamestate, targetMove ):
		"""Log any common per-frame things

		Args:
			gamestate (gamestate.GameState): A gamestate object to log
		"""
		# opponent_state = None
		# ai_state = None
		# count = 0
		# for i, player in gamestate.players.items():
		# 	if count == 0:
		# 		ai_state = player
		# 		count += 1
		# 	elif count == 1:
		# 		opponent_state = player
		# 		count += 1
		# if not ai_state:
		# 	return
		ai_state = next(iter( gamestate.players.values() ))

		self.log( 'Frame', gamestate.frame )
		self.log( 'Character', str(ai_state.character) )
		self.log( 'Target Move', str(targetMove) )
		self.log( 'P1 x', str(ai_state.position.x) )
		self.log( 'P1 y', str(ai_state.position.y) )
		self.log( 'P1 Action', str(ai_state.action) )
		self.log( 'P1 Action Frame', str(ai_state.action_frame) )


class DolphinController():

	def __init__( self, exePath ):
		
		self.exePath = exePath
		self.rootFolder = os.path.dirname( self.exePath )
		parentFolder = os.path.dirname( __file__ )
		self.userFolder = os.path.join( parentFolder, 'Dolphin User Folder' )
		self.outputFolder = os.path.join( parentFolder, 'Frames' )

		# State tracking
		self.gamePaused = False
		self.inputtingMove = False
		self.performingMove = False
		self.currentCharId = -1 # CSS ID
		self.currentCharacter = None # Will become an enum of Character
		self.charactersProcessed = []
		self.currentMoveIndex = 0 # Index into the Move Enums for moves to perform
		self.currentMove = None
		self.matchIndex = 0
		self.lastAction = None

		self.maxFrameCount = -1 # Will be a maximum number of frames not expected to be exceeded for a move (across all characters)

		self.validateInstall()
		
		# Print out version info
		print( 'Found Dolphin:                ' + self.exePath )
		
		# Set up logging in debug mode; this will create a CSV file describing progress
		if debugging:
			self.log = CustomLogger()
		else:
			self.log = None

		self.stopAllDolphinInstances()

		# Create the Console object for interfacing with the game, and controllers
		self.console = melee.Console( path=self.rootFolder, 
										dolphin_home_path=self.userFolder, 
										tmp_home_directory=False,
										copy_home_directory=False,
										slippi_address='127.0.0.1', 
										online_delay=0, 
										# blocking_input=True, 
										logger=self.log, 
										gfx_backend='D3D', # Todo: Test quality against D3D12
										save_replays=False )
		self.p1Controller = melee.Controller( console=self.console, port=1, type=melee.ControllerType.STANDARD )
		self.p4Controller = melee.Controller( console=self.console, port=4, type=melee.ControllerType.STANDARD )

		# Handle CTRL-C on command line to cancel automation
		signal.signal( signal.SIGINT, self.cancelAutomation )
		
		# Validate the disc path
		if os.path.exists( discPath ):
			print( 'Found DHS Disc:               ' + discPath )
		else:
			print( 'DHS Disc path is invalid or not set; unable to find the disc at this location:' )
			print( discPath )
			sys.exit( 1 )

		# Check how many characters and moves are to be collected
		if collectAllCharacters:
			charCount = '{} (all)'.format( len(charsToCollect) )
		else:
			charCount = str( list(charsToCollect.values()).count(True) )
		if collectAllMoves:
			moveCount = '{} (all)'.format( len(Move) )
		else:
			moveCount = str( [move.enabled for move in Move].count(True) )

		# Print current optional settings
		print( 'Debug Mode:                   ' + str(debugging) )
		print( 'Recording enabled:            ' + str(recordingEnabled) )
		print( 'Skip collected frames:        ' + str(skipCollectedFrames) )
		print( 'Characters to capture:        ' + charCount )
		print( 'Moves to capture:             ' + moveCount )

		# Run the console (start Dolphin) and connect to it
		print( 'Starting emulation and connecting to console...' )
		self.console.run( iso_path=discPath )

		# Wait until Dolphin has started
		# timeout = 10 # Time in seconds before giving up
		# timeStart = time.perf_counter()
		# while not self.isRunning:
		# 	if time.perf_counter() - timeStart > timeout:
		# 		print( 'Dolphin could not be started!' )
		# 		sys.exit( 6 )
		# 	else:
		# 		time.sleep( 1 )
		# print( 'waited for ' + str((time.perf_counter() - timeStart)/1000) + ' milliseconds' )

		time.sleep( 3 )
		#self.targetRenderWindow()
		# self.renderWindow = self.getDolphinRenderWindow()
		# self.windowDeviceContext = win32gui.GetWindowDC( self.renderWindow )

		#time.sleep( 3 )
		# timeout = 30
		# bgColor = 0
		# while bgColor == 0:
		# 	try:
		# 		# Sample a pixel on the other side of the black bar
		# 		bgColor = win32gui.GetPixel( windowDeviceContext, 314, 60 ) # Must measure a ways below the title bar and edge
		# 	except Exception as err:
		# 		# With normal operation, the method may raise an exception 
		# 		# if the window can't be found or is minimized.
		# 		if err.args[0] != 0:
		# 			raise err

		# 	if timeout < 0:
		# 		print( 'Timed out while waiting for the game to start' )
		# 		return ''

		# 	time.sleep( 1 )
		# 	timeout -= 1

		# Connect to the console
		if not self.console.connect():
			print( "Unable to connect to the console." )
			sys.exit( 3 )
		print( "Connection established." )

		# Connect controllers
		print( "Connecting controllers to console..." )
		if not self.p1Controller.connect() or not self.p4Controller.connect():
			print( "Unable to connect the controllers." )
			sys.exit( 4 )
		print( "Controllers connected." )

	def validateInstall( self ):
		if not os.path.exists( self.exePath ):
			raise Exception( 'The Dolphin executable path is invalid or has not yet been set.' )

		dhsSetupFilePath = os.path.join( self.userFolder, 'DHS Setup.txt' )
		if not os.path.exists( dhsSetupFilePath ):
			raise Exception( 'The Dolphin installation seems to be missing DHS project files; be sure to follow setup in "Set-up and workflow.txt" to get started.' )
			
		# Make sure that Dolphin is in 'portable' mode
		portableFile = os.path.join( self.rootFolder, 'portable.txt' )
		if not os.path.exists( portableFile ):
			raise Exception( 'Dolphin is not in portable mode!' )

	@property
	def isRunning( self ):

		""" Describes whether Dolphin is still running. """

		if not self.console._process: # Hasn't been started
			return False

		return ( self.console._process.poll() == None ) # None means the process is still running; anything else is an exit code

	def getVersion( self ): # Doesn't work with Slippi-Dolphin?!

		returnCode, output = cmdChannel( '"{}" --version'.format(self.exePath) )

		if returnCode == 0:
			return output
		else:
			return 'N/A'

	def stopAllDolphinInstances( self ):
		
		""" Includes stopping instances not started by this program. """

		# Check for other running instances of Dolphin
		processFound = False
		for process in psutil.process_iter():
			if process.name() in ( 'Dolphin.exe', 'Slippi Dolphin.exe' ):
				process.terminate()
				processFound = True
				print( 'Stopped an older Dolphin process not started by this script.' )
		
		if processFound:
			time.sleep( 2 )

	def stopThePresses( self ):

		""" Stop everything and write the log file. """
		
		# Check if emulation is still running
		if self.console._process is None:
			self.console.stop()

		if self.log:
			self.log.writelog()
			print( "Log file created: " + self.log.filename )
		
		# Remove the temp dir if one is being used
		elif self.console.temp_dir:
			# Emulation already stopped; just remove the temp dir
			shutil.rmtree( self.console.temp_dir )
			self.console.temp_dir = None

	def cancelAutomation( self, sig, frame ):
	
		print( "" ) # Because the ^C will be on the terminal
		self.stopThePresses()

		print( "Job aborted." )
		sys.exit( 2 )

	def getMoveFolder( self, moveName ):

		return os.path.join( self.outputFolder, charNames[self.currentCharId], moveName )

	def needMovesForCurrentChar( self ):

		""" Checks if there are any moves that need to be collected for the current 
			(newly selected) character. This is only relavant if skipCollectedFrames is True, 
			and prevents loading a character if requested moves are already collected. """

		char = charNames[self.currentCharId]

		if collectAllMoves:
			for move in Move:
				if move == Move.JAB_2 and char not in hasJab2:
					continue
				elif move == Move.JAB_3 and char not in hasJab3:
					continue
				elif move == Move.JAB_RAPID and char not in hasJabRapid:
					continue

				# Check if any files (frame images) are in this folder
				moveFolder = self.getMoveFolder( move.label )
				if not os.path.exists( moveFolder) or not os.listdir( moveFolder ):
					return True
		else:
			for move in Move:
				if not move.enabled:
					continue
				elif move == Move.JAB_2 and char not in hasJab2:
					continue
				elif move == Move.JAB_3 and char not in hasJab3:
					continue
				elif move == Move.JAB_RAPID and char not in hasJabRapid:
					continue

				# Check if any files (frame images) are in this folder
				moveFolder = self.getMoveFolder( move.label )
				if not os.path.exists( moveFolder) or not os.listdir( moveFolder ):
					return True
		
		return False

	def selectNextCharacter( self ):

		""" Determines which character to select on the CSS to capture frames for next. 
			Returns a Character enum object. """

		# The very first character index will be 0
		self.currentCharId += 1

		if not collectAllCharacters:
			# Increment internal character ID and look for the next enabled character
			while not charsToCollect.get( self.currentCharId ) and self.currentCharId < 0x19:
				self.currentCharId += 1

		if self.currentCharId >= 0x19:
			return None

		# Move on to the next character if we've already collected everything for this one
		if skipCollectedFrames and not self.needMovesForCurrentChar():
			print( 'All requested moves already collected for {}.'.format(charNames[self.currentCharId]) )
			return self.selectNextCharacter()

		# Convert from CSS ID to Internal Character ID
		nextCharacter = melee.to_internal( self.currentCharId )
		charName = charNames[self.currentCharId]
		print( 'Character set to {} (internal: ID {}).'.format(charName, nextCharacter.value) )

		# Reset the current move index
		self.currentMoveIndex = 0
		
		return nextCharacter

	def selectNextMove( self ):

		""" Determines which move to capture frames for next. 
			Returns a Move enum object. """

		# The very first move index will be 1
		self.currentMoveIndex += 1
		if self.currentMoveIndex > len( Move ):
			return None
		move = Move( self.currentMoveIndex )

		if not collectAllMoves:
			# Increment move index and look for the next enabled move
			while not move.enabled:
				self.currentMoveIndex += 1
				if self.currentMoveIndex > len( Move ):
					return None
				move = Move( self.currentMoveIndex )

		# Skip Jab 2/3/etc. on characters that don't have them
		charName = charNames[self.currentCharId]
		if move == Move.JAB_2 and charName not in hasJab2:
			print( 'Skipping jab 2 for {}, since they do not have this move.'.format(charName) )
			return self.selectNextMove()
		elif move == Move.JAB_3 and charName not in hasJab3:
			print( 'Skipping jab 3 for {}, since they do not have this move.'.format(charName) )
			return self.selectNextMove()
		elif move == Move.JAB_RAPID and charName not in hasJabRapid:
			print( 'Skipping rapid jab for {}, since they do not have this move.'.format(charName) )
			return self.selectNextMove()

		# Move on to the next move if we've already collected this one
		elif skipCollectedFrames:
			# Check if any files (frame images) are already in a folder for the current move
			moveFolder = self.getMoveFolder( move.label )
			if os.path.exists( moveFolder) and os.listdir( moveFolder ):
				moveName = move.label
				print( '{}{} has already been collected for {}.'.format(moveName[0].upper(), moveName[1:], charNames[self.currentCharId]) )
				return self.selectNextMove()

		print( 'Move set to ' + move.label + '.' )

		return move

	def enterMainLoop( self ):

		framedata = melee.framedata.FrameData()

		firstTimeReachedCss = False
		returningToCss = False
		nextCharacterChosen = False
		printedSlpVersion = False
		framesBetweenMoves = 0

		#waitFrames = 0

		# Main loop
		while True:
			# Ensure the emulator is still running
			if not self.isRunning:
				print( 'Emulation is no longer detected.' )
				break

			# "step" to the next frame
			elif self.gamePaused:
				time.sleep( .0167 ) # Delay for approximately one frame (don't need to be exact)

			else:
				try:
					gamestate = self.console.step()
					if gamestate is None:
						continue
				except:
					ms = self.console.processingtime * 1000
					print( 'Console gamestate lost connection after {} ms.'.format(ms) )
					break

			# Give a warning if we're taking too long to process frames (besides when the game is paused)
			if debugging and self.console.processingtime > .015:
				print( "WARNING: Last frame took " + str(self.console.processingtime) + " s to process." )

			# What menu are we in?
			if gamestate.menu_state == melee.Menu.STAGE_SELECT:
				# Select Dreamland
				melee.menuhelper.MenuHelper.choose_stage( melee.Stage.DREAMLAND, gamestate, self.p1Controller )
				nextCharacterChosen = False

			elif gamestate.menu_state in [melee.Menu.IN_GAME, melee.Menu.SUDDEN_DEATH]:

				if not printedSlpVersion:
					print( 'Reached in-game. SLP version: ' + self.console.slp_version )
					printedSlpVersion = True

				# Slippi Online matches assign you a random port once you're in game that's different
				#   than the one you're physically plugged into. This helper will autodiscover what
				#   port we actually are.
				discovered_port = melee.gamestate.port_detector( gamestate, self.currentCharacter, 0 )
				if discovered_port > 0:
					character = gamestate.players[1]

					if framesBetweenMoves > 300:
						print( 'Automation seems to have gotten stuck. ;_;' )
						framesBetweenMoves = 0

					# Setup the match environment if it has just started
					if matchFramesCounter <= 300:
						if recordingEnabled:
							self.configureEnvironment( matchFramesCounter, character )
						else:
							self.p1Controller.release_all()
						matchFramesCounter += 1
						continue # To skip logging so far

					elif self.performingMove and ( character.action_frame == 0 or character.action_frame == 1 ):
						# Still need to release buttons from performing the move
						self.p1Controller.release_all()

						if recordingEnabled:
							# Pause game execution
							self.pressButton( Button.BUTTON_START, .02 )

							# Collect screenshots
							self.captureFrames( character, framedata )

							# Unpause game execution
							self.pressButton( Button.BUTTON_START, .02 )
							time.sleep( .017 )

						self.performingMove = False
						self.currentMove = None

					# Continue inputting button combinations to perform the current move
					elif self.inputtingMove:
						self.inputMove( character, framedata )

					# Wait for a standing animation to input a move
					elif character.action == Action.STANDING and not returningToCss:

						# if waitFrames > 0:
						# 	print( 'Waiting... (waitFrames = {})'.format(waitFrames) )
						# 	waitFrames -= 1
							
						# Move the character to the left if they're too far right
						if character.position.x > 10:
							# Roll to the left
							self.p1Controller.press_shoulder( Button.BUTTON_L, .5 )
							self.p1Controller.tilt_analog( Button.BUTTON_MAIN, 0, .5 )
							time.sleep( .033 )
							self.p1Controller.release_all()

						# Select the move to perform and collect frames for
						elif not self.currentMove:
							self.currentMove = self.selectNextMove()
							framesBetweenMoves = 0

							# If None, all moves selected by the user have been performed
							if not self.currentMove:
								print( 'Done collecting moves for ' + charNames[self.currentCharId] + '.' )
								returningToCss = True
								self.returnToCSS()

						# Start inputting button combinations to perform the current move
						else:
							self.inputtingMove = True
							#waitFrames = 120
							self.inputMove( character, framedata )

					else:
						self.p1Controller.release_all()

				matchFramesCounter += 1
				framesBetweenMoves += 1
				self.lastAction = character.action

				# Log this frame's detailed info if we're in game
				if self.log:
					self.log.logframe( gamestate, self.currentMove )
					self.log.writeframe()

			elif gamestate.menu_state == melee.Menu.CHARACTER_SELECT:
				
				if not firstTimeReachedCss:
					print( 'Slippi Dolphin version:      ', self.console.version ) # Not available earlier
					print( 'Reached the CSS.' )
					firstTimeReachedCss = True

				# Choose the next P1 character to capture frames for
				if not nextCharacterChosen:
					# This should be reached only for the first frame of being on the CSS (for the first time or subsequent returns)
					matchFramesCounter = 0
					returningToCss = False
					self.lastAction = None

					self.currentCharacter = self.selectNextCharacter()
					if self.currentCharacter:
						nextCharacterChosen = True
					else:
						# Check if there was more than one character being collected
						charCount = list( charsToCollect.values() ).count( True )
						if not collectAllCharacters and charCount == 1:
							print( 'Job complete. All moves collected!' )
						else:
							print( 'Job complete. All characters processed!' )
						break

				# Select the characters for P1 and P4
				melee.menuhelper.MenuHelper.choose_character( self.currentCharacter, gamestate, self.p1Controller, 0, 0, start=True )
				melee.menuhelper.MenuHelper.choose_character( Character.CPTFALCON, gamestate, self.p4Controller, 0, 2 )

			else:

				# # If we're not in game, don't log the frame
				# if self.log:
				# 	self.log.skipframe()

				melee.MenuHelper.choose_versus_mode( gamestate, self.p4Controller )

		# Shut down everything
		self.stopThePresses()

	def pressButton( self, button, delaySeconds=.0167 ):

		""" Presses a button for about a frame, and then releases it. 
			Useful for making control inputs while the game is paused. """

		self.p1Controller.press_button( button )
		time.sleep( delaySeconds )
		self.p1Controller.release_button( button )

	def configureEnvironment( self, matchFramesCounter, character ):

		""" Turn on hitbox display, disable rendering of stage/HUD, etc. """

		# Rotate the camera to initiate the Camera Mode 9 code
		if matchFramesCounter >= 100 and matchFramesCounter < 110:
			self.p1Controller.tilt_analog( Button.BUTTON_C, .8, .5 )

		# Pause game execution (so we don't input to character)
		elif matchFramesCounter == 120:
			self.p1Controller.press_button( Button.BUTTON_START )
			self.gamePaused = True

		# Turn on hitbox display with R + D-Pad Right
		elif matchFramesCounter == 130:
			self.p1Controller.press_button( Button.BUTTON_R )
			self.p1Controller.press_button( Button.BUTTON_D_RIGHT )

		# Disable stage rendering by pressing X + D-pad Down three times
		elif matchFramesCounter == 140:
			self.p1Controller.press_button( Button.BUTTON_X )
			self.p1Controller.press_button( Button.BUTTON_D_DOWN )
		elif matchFramesCounter == 150:
			self.p1Controller.press_button( Button.BUTTON_X )
			self.p1Controller.press_button( Button.BUTTON_D_DOWN )
		elif matchFramesCounter == 160:
			self.p1Controller.press_button( Button.BUTTON_X )
			self.p1Controller.press_button( Button.BUTTON_D_DOWN )
		elif matchFramesCounter == 170 and self.matchIndex > 0: # Bug?
			self.p1Controller.press_button( Button.BUTTON_X )
			self.p1Controller.press_button( Button.BUTTON_D_DOWN )
		
		# Show action state display
		elif matchFramesCounter == 180:
			self.p1Controller.press_button( Button.BUTTON_Y )
			self.p1Controller.press_button( Button.BUTTON_D_DOWN )
			
		# Unpause game execution
		elif matchFramesCounter == 190:
			self.p1Controller.press_button( Button.BUTTON_START )
			time.sleep( .0167 )
			self.gamePaused = False
			self.matchIndex += 1
			print( 'Match environment configured.' )

		else:
			self.p1Controller.release_all()

	def returnToCSS( self ):
		
		""" Enter the button combination to end the match. """

		self.p1Controller.release_all()

		# X + D-pad up substituting for Start (since we're in debug mode)
		self.p1Controller.press_button( Button.BUTTON_X )
		self.p1Controller.press_button( Button.BUTTON_D_UP )

		time.sleep( 1.5 )
		
		self.p1Controller.press_button( Button.BUTTON_L )
		self.p1Controller.press_button( Button.BUTTON_R )
		self.p1Controller.press_button( Button.BUTTON_A )

		time.sleep( .5 )

		self.p1Controller.release_all()

	def inputMove( self, character, framedata ):

		""" Inputs button combinations to perform specifc moves. In some cases this method may 
			be called multiple times over the course of several game frames. In all cases, the 
			desired move is expected to begin on the next game frame once 'self.performingMove'
			has been set. """

		maxFrameCount = -1
		move = self.currentMove

		# Ground based
		if move == Move.DASH_ATTACK or move == Move.DASH_GRAB:
			# Press the Main joy stick to the right to start running
			if not character.action == Action.RUNNING:
				self.p1Controller.tilt_analog_unit( Button.BUTTON_MAIN, 1, 0 )

			else: # Wait until running and then press A or Z
				if move == Move.DASH_ATTACK:
					self.p1Controller.press_button( Button.BUTTON_A )
				else:
					self.p1Controller.press_button( Button.BUTTON_Z )

					if self.currentCharacter in ( Character.YOSHI, Character.SAMUS, Character.LINK, Character.YLINK ):
						maxFrameCount = 97
					else:
						maxFrameCount = 55
				
				self.performingMove = True

		elif move == Move.DOWN_B_GROUND or move == Move.DOWN_SMASH:
			self.p1Controller.tilt_analog_unit( Button.BUTTON_MAIN, 0, -1 )

			if move == Move.DOWN_B_GROUND:
				self.p1Controller.press_button( Button.BUTTON_B )
			else:
				self.p1Controller.press_button( Button.BUTTON_A )
			self.performingMove = True

		elif move == Move.DOWN_TILT:
			self.p1Controller.tilt_analog_unit( Button.BUTTON_MAIN, 0, -.2 )
			self.p1Controller.press_button( Button.BUTTON_A )
			self.performingMove = True

		elif move == Move.FORWARD_SMASH:
			self.p1Controller.tilt_analog_unit( Button.BUTTON_MAIN, 1, 0 )
			self.p1Controller.press_button( Button.BUTTON_A )
			self.performingMove = True

		elif move == Move.FORWARD_TILT:
			self.p1Controller.tilt_analog_unit( Button.BUTTON_MAIN, .2, 0 )
			self.p1Controller.press_button( Button.BUTTON_A )
			self.performingMove = True

		# elif move == Move.GETUP_ATTACK_FRONT:

		# elif move == Move.GETUP_ATTACK_BACK:

		elif move == Move.GRAB:
			self.p1Controller.press_button( Button.BUTTON_Z )
			self.performingMove = True

			if self.currentCharacter in ( Character.YOSHI, Character.SAMUS, Character.LINK, Character.YLINK ):
				maxFrameCount = 95
			else:
				maxFrameCount = 42

		elif move == Move.JAB_1:
			self.p1Controller.press_button( Button.BUTTON_A )
			self.performingMove = True
			maxFrameCount = 35

		elif move in ( Move.JAB_2, Move.JAB_3, Move.JAB_RAPID ):
			maxFrameCount = 55

			# Determine the next action frame to press A on (these are not the only frames possible, but work well here)
			if self.currentCharacter == Character.DOC and character.action == Action.NEUTRAL_ATTACK_2: # For Jab 3
				transitionFrame = 17
			elif self.currentCharacter == Character.CPTFALCON:
				if move == Move.JAB_3: # The elusive Gentleman
					if character.action == Action.STANDING:
						transitionFrame = 0
					else:
						self.p1Controller.release_all()
						return
				elif move == Move.JAB_RAPID:
					transitionFrame = 7
				else:
					transitionFrame = 14
			elif self.currentCharacter in ( Character.LINK, Character.YLINK ) and move == Move.JAB_RAPID:
				transitionFrame = 7
			elif self.currentCharacter == Character.MEWTWO: # Will only be here for JAB_RAPID
				transitionFrame = 9
				maxFrameCount = 70
			elif self.currentCharacter == Character.GAMEANDWATCH: # Will only be here for JAB_RAPID
				transitionFrame = 6
			elif self.currentCharacter == Character.MARTH: # Will only be here for JAB_2
				transitionFrame = 20
			else:
				transitionFrame = 14

			# Press the A button to transition to the next jab state
			#print( 'Before... action frame: {}      transition frame: {}      action: {}      last action: {}'.format(character.action_frame, transitionFrame, character.action, self.lastAction) )
			if character.action_frame >= transitionFrame and not self.p1Controller.current.button[Button.BUTTON_A]:
				#print( 'After...       (pressing A)' )
				self.p1Controller.press_button( Button.BUTTON_A )
				
				# Determine whether we're about to start the desired move
				if move == Move.JAB_2 and character.action == Action.NEUTRAL_ATTACK_1: self.performingMove = True
				elif move == Move.JAB_3 and character.action == Action.NEUTRAL_ATTACK_2: self.performingMove = True
				elif move == Move.JAB_3 and self.currentCharacter == Character.CPTFALCON and self.lastAction == Action.NEUTRAL_ATTACK_2: self.performingMove = True
				elif move == Move.JAB_RAPID:

					if character.action == Action.NEUTRAL_ATTACK_1:
						# Expecting Mewtwo or Game & Watch here
						if self.currentCharacter in ( Character.MEWTWO, Character.GAMEANDWATCH ) and character.action_frame == transitionFrame + 2:
							self.performingMove = True
							
					elif character.action == Action.NEUTRAL_ATTACK_2:
						# A few characters don't have a jab 3, but they do have a rapid jab!
						if self.currentCharacter in ( Character.FALCO, Character.FOX, Character.KIRBY ):
							self.performingMove = True

						# Link and Young Link can follow up jab 2 with jab 3 OR a rapid jab
						elif self.currentCharacter in ( Character.LINK, Character.YLINK ) and character.action_frame == transitionFrame + 2:
							self.performingMove = True
					
					elif character.action == Action.NEUTRAL_ATTACK_3:
						# Just for Captain Falcon
						self.performingMove = True
			else:
				self.p1Controller.release_all()

		# elif move == Move.LEDGE_ATTACK_LOW:

		# elif move == Move.LEDGE_ATTACK_HIGH:

		# elif move == Move.NEUTRAL_B_GROUND:

		# elif move == Move.ROLL_FORWARD:

		# elif move == Move.ROLL_BACK:

		# elif move == Move.SIDE_B_GROUND:

		# elif move == Move.SPOT_DODGE:

		# elif move == Move.UP_B_GROUND:

		# elif move == Move.UP_SMASH:

		# elif move == Move.UP_TILT:


		# # Air based
		# elif move == Move.AIR_DODGE:

		# elif move == Move.BACK_AIR:

		# elif move == Move.DOWN_AIR:

		# elif move == Move.DOWN_B_AIR:

		# elif move == Move.FORWARD_AIR:

		# elif move == Move.NEUTRAL_AIR:

		# elif move == Move.NEUTRAL_B_AIR:

		# elif move == Move.SIDE_B_AIR:

		# elif move == Move.UP_AIR:

		# elif move == Move.UP_B_AIR:

		else:
			# Failsafe; collect idle standing and move on (otherwise we'd reach an infinite loop)
			print( 'Warning! Attempting to collect a move that has not been programmed yet!: {}'.format(move) )
			self.performingMove

		# The target move should begin next frame if we're done inputting commands for it
		if self.performingMove:
			self.inputtingMove = False

			if maxFrameCount != -1:
				self.maxFrameCount = maxFrameCount

	def captureFrames( self, character, framedata ):

		""" Gets screenshots of all frames for the current move. """

		moveName = self.currentMove.label

		# Check how many frames are in this animation
		frameCount = framedata.frame_count( self.currentCharacter, character.action )
		if frameCount == -1: # Sanity check (might be capturing the wrong move)
			print( 'Warning! Unable to get frameCount for {}; got -1 frameCount for {} (move ID {}).'.format(moveName, character.action, character.action.value) )
			frameCount = self.maxFrameCount

		# Create the folder for these frames
		moveFolder = os.path.join( self.outputFolder, charNames[self.currentCharId], moveName )
		os.makedirs( moveFolder, exist_ok=True )

		print( 'Capturing {} frames for {} ({}, move ID {}). Current frame: {}'.format(frameCount, moveName, character.action, character.action.value, character.action_frame) )
		
		self.renderWindow = self.getDolphinRenderWindow()
		#self.windowDeviceContext = win32gui.GetWindowDC( self.renderWindow )
		tic = time.perf_counter()

		for i in range( character.action_frame, frameCount + 1 ):
			savePath = os.path.join( moveFolder, str(i) + '.png' )
			# if debugging:
			# 	frameStartTime = time.perf_counter_ns()
			self.saveScreenshot( savePath )
			# if debugging:
			# 	print( 'Time to save screenshot: ' + str((time.perf_counter_ns()-frameStartTime)/1000000) + ' ms' ) # Takes ~70-120 ms

			self.pressButton( Button.BUTTON_Z )
			
			time.sleep( .01 ) # Ensures the frame changes before we get a screenshot

		# Print screenshotting stats
		toc = time.perf_counter()
		timePerShot = ( toc-tic ) / ( frameCount + 1 )
		print( 'Took {:<.5} seconds to capture {} frames (averaging {} s per frame).'.format(toc-tic, frameCount+1, timePerShot) )

	def targetRenderWindow( self ):
		
		# Seek out the Dolphin rendering window and wait for the game to pause
		try:
			self.renderWindow = self.getDolphinRenderWindow()
			self.windowDeviceContext = win32gui.GetWindowDC( self.renderWindow )
		except Exception as err:
			print( 'Unable to target the Dolphin render window; {}'.format(err) )
			raise err

	def saveScreenshot( self, savePath ):

		""" Seeks out the Dolphin rendering window, takes a screenshot, 
			and then gets/returns the filepath to that screenshot. """

		# Seek out the Dolphin rendering window and wait for the game to pause
		# try:
		# 	renderWindow = self.getDolphinRenderWindow()
		# except Exception as err:
		# 	print( 'Unable to target the Dolphin render window; {}'.format(err) )
		# 	return ''

		# The character should be posed, and game paused
		# todo: edit to work on multiple monitors. code here: https://github.com/python-pillow/Pillow/issues/1547
		try:
			dimensions = win32gui.GetWindowRect( self.renderWindow )
			image = ImageGrab.grab( dimensions )
		except Exception as err:
			# Likely due to quiting the program just before this call
			print( 'Unable to grab render window screenshot; {}'.format(err) )

		image.save( savePath )

		# Validate image dimensions
		# if image.width != 1920 or image.height != 1080:
		# 	print( 'Warning! Invalid screenshot dimensions: {}x{}'.format(image.width, image.height) )
		# 	return ''

		return savePath

	def _windowEnumsCallback( self, windowId, processList ):

		""" Helper for EnumWindows to search for the Dolphin render window. 
			There will be multiple threads under the current process ID, but 
			it's expected to be the only 'Enabled' window with a parent. """

		processId = win32process.GetWindowThreadProcessId( windowId )[1]

		# Check if this has the target process ID, and is a child (i.e. has a parent)
		if processId == self.console._process.pid and win32gui.IsWindowEnabled( windowId ):
			# Parse the title to determine if it's the render window
			title = win32gui.GetWindowText( windowId )

			# Parse the title. Will be just "Dolphin" until the game is done booting
			#if title == 'Slippi Dolphin' or ( 'Slippi Dolphin' in title and '|' in title ):
			if title == 'Dolphin':
				processList.append( windowId )
				return False
		
		return True

	def getDolphinRenderWindow( self ):

		""" Searches all windows which share the current Dolphin process ID 
			and finds/returns the main render window. """

		if not self.isRunning:
			raise Exception( 'Dolphin is not running.' )

		processList = []
		try:
			win32gui.EnumWindows( self._windowEnumsCallback, processList )
		except Exception as err:
			# With normal operation, the callback will return False
			# and EnumWindows will raise an exception.
			if err.args[0] != 0:
				raise err

		if not processList:
			raise Exception( 'no processes found' )
		elif len( processList ) != 1:
			raise Exception( 'too many processes found' )

		return processList[0]


class GimpController():

	""" A wrapper for GIMP to check for installation/dependencies, 
		and handle post processing of frames collected from Dolphin. """

	def __init__( self ):

		self.gimpDir = ''
		self.gimpExe = ''
		self.pluginDir = ''

		# Analyze the version of GIMP installed, and check for needed plugins
		self.determineGimpPath()
		gimpVersion = self.getGimpProgramVersion()
		self.getGimpPluginDirectory( gimpVersion )
		createCspScriptVersion = self.getScriptVersion( 'python-fu-create-tri-csp.py' )
		finishCspScriptVersion = self.getScriptVersion( 'python-fu-finish-csp.py' )
		
		# Print out version info
		print( 'Found GIMP:                   v' + gimpVersion )
		print( '     create-tri-csp script:   ' + createCspScriptVersion )
		print( '     finish-csp script:       ' + finishCspScriptVersion )
		print( '     Executable directory:    ' + self.gimpDir )
		print( '     Plug-ins directory:      ' + self.pluginDir )

	def determineGimpPath( self ):

		""" Determines the absolute file path to the GIMP console executable 
			(the exe filename varies based on program version). """

		dirs = ( "C:\\Program Files\\GIMP 2\\bin", "{}\\Programs\\GIMP 2\\bin".format(os.environ['LOCALAPPDATA']) )
		
		# Check for the GIMP program folder
		for directory in dirs:
			if os.path.exists( directory ):
				break
		else:
			raise Exception( 'GIMP does not appear to be installed; unable to find program folder among these paths:\n\n' + '\n'.join(dirs) )
		
		# Check the files in the program folder for a 'console' executable
		for fileOrFolderName in os.listdir( directory ):
			if fileOrFolderName.startswith( 'gimp-console' ) and fileOrFolderName.endswith( '.exe' ):
				self.gimpDir = directory
				self.gimpExe = fileOrFolderName
				return

		else: # The loop above didn't break; unable to find the exe
			raise Exception( 'Unable to find the GIMP console executable in "{}".'.format(directory) )

	def getGimpProgramVersion( self ):
		returnCode, versionText = cmdChannel( '"{}\{}" --version'.format(self.gimpDir, self.gimpExe) )
		if returnCode == 0:
			return versionText.split()[-1]
		else:
			print( versionText ) # Should be an error message in this case
			return 'N/A'
		
	def getGimpPluginDirectory( self, gimpVersion ):

		""" Checks known directory paths for GIMP versions 2.8 and 2.10. If both appear 
			to be installed, we'll check the version of the executable that was found. """

		userFolder = os.path.expanduser( '~' ) # Resolves to "C:\Users\[userName]"
		v8_Path = os.path.join( userFolder, '.gimp-2.8\\plug-ins' )
		v10_Path = os.path.join( userFolder, 'AppData\\Roaming\\GIMP\\2.10\\plug-ins' )

		found_v8 = os.path.exists( v8_Path )
		found_v10 = os.path.exists( v10_Path )

		if found_v8 and found_v10:
			# Both versions seem to be installed. Use Gimp's version to decide which to use
			major, minor, _ = gimpVersion.split( '.' )
			if major != '2':
				self.pluginDir = ''
			if minor == '8':
				self.pluginDir = v8_Path
			else: # Hoping this path is good for other versions as well
				self.pluginDir = v10_Path

		elif found_v8: self.pluginDir = v8_Path
		elif found_v10: self.pluginDir = v10_Path
		else: self.pluginDir = ''

	def getScriptVersion( self, scriptFileName ):

		""" Scans the given script (a filename) for a line like "version = 2.2\n" and parses it. """

		scriptPath = os.path.join( self.pluginDir, scriptFileName )

		if os.path.exists( scriptPath ):
			with open( scriptPath, 'r' ) as script:
				for line in script:
					line = line.strip()

					if line.startswith( 'version' ) and '=' in line:
						return line.split( '=' )[-1].strip()
			
		return 'N/A'


if __name__ == '__main__':
	args = sys.argv

	# Check for invalid program configuration (no characters or no moves selected)
	if not collectAllCharacters and not any( charsToCollect.values() ):
		print( 'No characters are selected for collection!' )
		sys.exit( 5 )
	elif not collectAllMoves and not any( [move.enabled for move in Move] ):
		print( 'No moves are selected for collection!' )
		sys.exit( 5 )
	
	if postProcessingEnabled:
		# Check for GIMP
		try:
			gimp = GimpController()
		except Exception as error:
			print( error )
			sys.exit( 1 )
	else:
		gimp = None

	# Check for the Slippi-Dolphin install
	try:
		dolphin = DolphinController( dolphinExePath )
	except Exception as error:
		print( error )
		sys.exit( 1 )

	# Backup pre-existing snapshots
	# if os.path.exists:

	# Start the main game loop and automation
	dolphin.enterMainLoop()