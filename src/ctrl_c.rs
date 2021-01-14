// This file contains code to handle Ctrl-C.

use super::signal::Signal;

// captures Ctrl-C and messages it as a Signal::Exit message via the given sender
pub fn handle(sender: std::sync::mpsc::Sender<Signal>) {
  ctrlc::set_handler(move || {
    sender.send(Signal::Exit).unwrap();
  })
  .unwrap();
}