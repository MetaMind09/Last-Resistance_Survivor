
function ScoringMixin:ResetScores()

	//do not reset the score for players 
	//these are kept until the mapchange
	/* 
 if not self:isa("Player") then
    self.score = 0
  end

  self.kills = 0
  self.assistkills = 0
  self.deaths = 0    
  */
  self.commanderTime = 0
  self.playTime = 0
  self.marineTime = 0
  self.alienTime = 0

end

