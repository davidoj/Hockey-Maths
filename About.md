# About Hockey Maths

Hockey Maths is a small game that aims to be a fun way for people to
practice their ability to quickly carry out the for operactions. There
are suggestions that struggling students achieving a high level of
fluency also referred to as "automaticity" can [improve][pegg1] their
general performace in mathematics.

The gameplay

## Present State

Presently, Hockey Maths displays a question to a user and invites a
typed response. A correct response will cause the hockey stick on the
left to display a hitting-the-ball animation and generate a new
question.

Questions already answered are stored in a database, and new questions
are randomly either selected from this database or generated as a
modification to existing questions. There is some scaling in that fast
correct responses to questions will cause those questions to be less
likely to be asked in the future, but this needs a lot of tweaking to
be useful.

## Planned Features in approximate order of priority

### Pedagogical

* Instant and clear feedback regarding correct/incorrect responses
* Allow multiplication and division questions to be asked
* Test & tweak algorithms for deciding which questions to present
  students
* Include game speed as a parameter tunable in response to player
  fluency
* Allow students to view their performance over time
* Allow questions with more terms to be asked
* Possibly some basic instruction graphics/animations when students
  are struggling with a particular question, but this is not presently
  indended to be instructional software.

### General Use

* Selectable user profiles so each user can get questions personalised
  to them
* Selectable question generation parameters (depending on how well
  automatic systems work)
* Central reporting of parameter and performance data so I can
  evaluate the effectiveness of the program
* Compatibility with iOS and Android devices


### Fun

* Goals scored against player if too many incorrect or
  too slow responses
* Goals scored by the player after sufficiently many correct responses
* Reward animations & sounds for scoring goals & winning a game
* Powerups and customisation as rewards for making long-term progress
* Possibly some sort of time-limited free play mode between practice
  sessions
* Possibly possibly two player modes



[pegg1]:  http://www.emis.de/proceedings/PME29/PME29RRPapers/PME29Vol4PeggEtAl.pdf "The Effect of Improved Automaticity of Basic Number Skills on Persistently Low-Achieving Pupils"
