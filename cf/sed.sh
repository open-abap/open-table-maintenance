#!/bin/bash
if [[ "$OSTYPE" == "darwin"* ]]; then
  exec "gsed" "$@"
else
  exec "sed" "$@"
fi