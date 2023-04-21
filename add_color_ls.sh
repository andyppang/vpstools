#!/bin/bash
# Check if the alias for ls already exists
if ! grep -q "alias ls='ls --color=auto'" ~/.bashrc; then
  # Add the alias to ~/.bashrc
  echo "alias ls='ls --color=auto'" >> ~/.bashrc
  # Reload the ~/.bashrc file
  source ~/.bashrc echo "The alias for ls has been added." else echo "The alias for ls already exists."
fi
