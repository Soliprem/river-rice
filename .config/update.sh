#!/bin/bash

cd "$HOME"/.local/src/rices/river-rice || exit 1
sudo cp -r "$HOME"/.config/foot .
sudo cp -r "$HOME"/.config/waybar .
sudo cp -r "$HOME"/.config/rofi .
sudo cp -r "$HOME"/.config/river .
