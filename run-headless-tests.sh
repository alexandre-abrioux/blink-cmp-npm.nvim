#!/bin/bash
for file in $(find lua/blink-cmp-npm -name '*_headlessspec.lua'); do
  echo "Running tests in: $file"
  nvim --headless -c "PlenaryBustedFile $file" -c "qa"
done
