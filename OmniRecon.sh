#!/bin/bash

# ========================================================
# 🛰️ OmniRecon – Glyph: The Info Drone
# ========================================================

# Glyph's welcoming function
glyph_welcome () {
    echo "----------------------------------------------------------------------------------"
    echo "Hello Commander, I'm Glyph, your Info Drone. Starting initialization procedures..."
    echo "----------------------------------------------------------------------------------"
}

# Call glyph_welcome
glyph_welcome

# Check if $1 was provided as input.
ATTEMPTS=0
MAX_ATTEMPTS=2
TARGET=""

# --- 1. Check for command-line argument ($1) ---
if [ -n "$1" ]; then # '-n' checks if string is not empty
    # If argument is provided, use it and skip the prompt loop.
    TARGET=$1
else
    # --- 2. If no argument, ask for input for the first time (without error message). ---
    read -rp "Please enter the mission target coordinates, Commander:" TARGET

    # --- 3. If input is empty, enter the retry loop. ---
    while [ -z "$TARGET" ] && [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
        # This message appears on subsequent attempts.
        echo "---------------------------------------------------------"
        echo "Warning: No coordinates provided in the previous attempt."

        read -rp "Unable to establish connection with the target, Commander. Verify that the coordinates provided are correct:" TARGET

        # Increase counter of ATTEMPTS
        ATTEMPTS=$((ATTEMPTS + 1))
    done

    # --- 4. Check if we failed after the loop. ---
    if [ -z "$TARGET" ]; then
        echo "----------------------------------------------------------------------"
        echo "Maximum number of attempts reached. Critical failure. Aborting mission."
        exit 1
    fi
fi

# --- 5. Proceed with the mission using the validated TARGET. ---
echo "---------------------------------------------------"
echo "Establishing connection to $TARGET, Commander."
echo "Connection established. Proceeding with the mission..."

# --- 6. Generating TIMESTAMP. ---
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
echo "---------------------------------------------------"
echo "The mission has begun at $TIMESTAMP..."

# --- 7. Proceeding with directory creation. ---
OUTPUT_DIR="glyph-missionlog-$TARGET-$TIMESTAMP"
echo "--------------------------------------------------------------------------"

# Check if OUTPUT_DIR exist 
if [ ! -d "./$OUTPUT_DIR" ]; then
    # If the directory does not exist, create it.
    mkdir -p "./$OUTPUT_DIR"
    echo "Directory $OUTPUT_DIR has been created for your mission logs, Commander!"
else
    # If the directory does exist, inform the user.
    echo "Mission's logs are stored in the $OUTPUT_DIR directory, Commander!"
fi

echo "---------------------------------------------------"
echo "# Standing by for your next assignment, Commander."