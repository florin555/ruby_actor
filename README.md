# Ruby Actor

Trying to solve following problems of Ruby Threads:
  
  - Don't swallow up errors, instead let them bubble up.
  - Possibility to have a graceful shutdown.

More features to be implemented:

  - Message passing between actors (inbox, outbox) and "piping together" two actors.
  - Actor that runs an external program and writes lines to the outbox.
