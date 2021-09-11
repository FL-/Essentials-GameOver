#===============================================================================
# * Game Over - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. When a switch is on, its activates a
# game over when the player lose a battle instead of going to last healing spot.
# Also, the Game Over event command back to work.
#
#===============================================================================
  
# The switch number that need to be ON in order to allows a game over
GAMEOVERSWITCH = 80

alias :_old_FL_pbStartOver :pbStartOver
def pbStartOver(gameover=false)
  if $game_switches[GAMEOVERSWITCH]
    pbLoadRpgxpScene(Scene_Gameover.new)
    return
  end
  _old_FL_pbStartOver(gameover)
end

class PokeBattle_Battle
  alias :_old_FL_pbLoseMoney :pbLoseMoney
  def pbLoseMoney
    return if $game_switches[GAMEOVERSWITCH]
    _old_FL_pbLoseMoney
  end
end

$need_save_reload = false

# Small adjust to fix an Essentials V19 reload issue
module SaveData
  class << self
    alias :_old_FL_load_all_values :load_all_values
    def load_all_values(save_data)
      if !$need_save_reload
        _old_FL_load_all_values(save_data)
        return
      end
      $game_temp.to_title = false
      $need_save_reload = false
      validate save_data => Hash
      load_values(save_data)
    end
  end
end

# Method created to Interpreter.command_end work in branch
class Interpreter
  def force_end
    command_end
    @list = [RPG::EventCommand.new, RPG::EventCommand.new]
    @index = 0
    @branch = [false]
  end
end

def go_to_title
  $need_save_reload = true
  pbMapInterpreter.force_end if pbMapInterpreter
  $game_screen.start_tone_change(Tone.new(-255, -255, -255), 0)
  $game_temp.to_title = true
end
  
# Below is the RPG Maker XP Scene_Gameover with a line commented, three lines
# added and one changed.
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
    Audio.me_fade(800) # added line
    # Prepare for transition
    Graphics.freeze
    # Dispose of game over graphic
    @sprite.bitmap.dispose
    @sprite.dispose
    # Execute transition
    Graphics.transition(1) # changed line (from 40 to 1)
    # Prepare for transition
    Graphics.freeze
    go_to_title # added line
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