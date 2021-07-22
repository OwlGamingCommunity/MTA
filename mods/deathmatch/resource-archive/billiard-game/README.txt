mta-billiard
===========

Billiard script for Multi Theft Auto.

![Screenshot](http://i.imgur.com/6VEXP.png)

About
-----

This is a billiard script, that was originally developped for LSS-RP.pl server.

Demonstration video: http://www.youtube.com/watch?v=vB5U1Sqy37U


It's (c) Wielebny 2012

Licence: CC-BY-SA - http://creativecommons.org/licenses/by-sa/3.0/deed.en

If you run this resource on your server, I would like to be attributed in game or your website.


How to use
----------

Just start the resource. It will create two billiard tables at Grove Street.
There's no commands to start the game, just approach them, and use your
mouse buttons to target and shoot.

Use /resettable <number> to reposition balls on table.

Script only simulates gaming physics. Enforcement of rules, point counting, etc. should be done by the players.

Customizing
-----------

You can edit table locations in billard.lua. They can be placed in different
dimensions and interiors. Table rotation is not supported ATM.

You should replace /resettable command with some kind of GUI.

You should alter broadcastCaptionedEvent in interaction.lua to suit your server.

You should consider extending this code and sharing back your changes. Main project repository is accessible at https://github.com/lpiob/mta-billiard

Todo
----
- Improve english translation.
- Table rotation.
- Cue hit angle isn't taken into calculation.
- Balls aren't rotating while moving.
- Better way for players to set shot force.
- Use all of the available animations.
- Physics algorithms could be improved.
- Other camera view-modes.


Credits
-------

Sounds are made by juskiddink <http://www.freesound.org/people/juskiddink/> and are licensed under the attribution license.

- http://www.freesound.org/people/juskiddink/sounds/108615/

