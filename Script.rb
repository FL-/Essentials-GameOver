#===============================================================================
# * Game Over - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. When a switch is on, its activates a
# game over when the player lose a battle instead of going to last healing spot.
#
#===============================================================================
# For this script to work, put it above main script section. After that,
# in PField_Visuals script section before line 
# 'if $PokemonGlobal.pokecenterMapId && $PokemonGlobal.pokecenterMapId>=0' add
# line 'pbLoadRpgxpScene(Scene_Gameover.new) if $game_switches[GAMEOVERSWITCH]'.
#
# If you wish to don't display the money lost message, in PokeBattle_Battle
# script section, after line 'moneylost=0 if $game_switches[NO_MONEY_LOSS]' add line
# 'moneylost=0 if (!canlose && $game_switches[GAMEOVERSWITCH])'.
#
# This script is the RPG Maker XP Scene_Gameover with a single line
# commented and two line added as you can see below, so you can define the
# game Over ME and graphic in the RPG Maker XP system database (F9).
# Please note that Essentials uses a different screen size (the default is
# 512x384), so the game over graphic must match.
# 
#===============================================================================

# The switch number that need to be ON in order to allows a game over
GAMEOVERSWITCH = 60 

# Using the equivalent of the commented line ($scene = Scene_Map.new)
# throws some strange behaviors, so I prefer to raise a reset at scene end

#==============================================================================
# ** Scene_Gameover
#------------------------------------------------------------------------------
#  This class performs game over screen processing.
#==============================================================================

class Scene_Gameover
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    # Make game over graphic
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.gameover($data_system.gameover_name)
    # Stop BGM and BGS
    $game_system.bgm_play(nil)
    $game_system.bgs_play(nil)
    # Play game over ME
    $game_system.me_play($data_system.gameover_me)
    # Execute transition
    Graphics.transition(120)
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepare for transition
    Graphics.freeze
    # Dispose of game over graphic
    @sprite.bitmap.dispose
    @sprite.dispose
    # Execute transition
    Graphics.transition(40)
    # Prepare for transition
    Graphics.freeze
    Audio.me_fade(800) # added line
    raise Reset.new # added line
    # If battle test
    if $BTEST
      $scene = nil
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Switch to title screen
#     $scene = Scene_Title.new # commented line
      $scene = nil; # added line
    end
  end
end