# Ruby Actor

Trying to solve following problems of Ruby Threads:
  
  - Don't swallow up errors, instead let them bubble up.
  - Possibility to have a graceful shutdown.

More features to be implemented:

  - Message passing between actors (inbox, outbox) and "piping together" two actors.

A special type of actor: one that runs an external program and writes lines to the outbox.

  - Send the program's output lines as events to the outbox.
  - Be able to shut down the program.
  - Detect if the program exits with an error.
