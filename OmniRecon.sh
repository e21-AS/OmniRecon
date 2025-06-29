#!/bin/bash

# ========================================================
# 🛰️ OmniRecon – Glyph: The Info Drone
# ========================================================

# --- SCRIPT FUNCTIONS ---

# Glyph's welcoming function
glyph_welcome () {
    echo "----------------------------------------------------------------------------------"
    echo "Hello Commander, I'm Glyph, your Info Drone. Starting initialization procedures..."
    echo "----------------------------------------------------------------------------------"
}

# Glyph's target validation function
# Validates whether input is a correct IPv4 address (0-255 per octet)
glyph_validate_target () {
    local target_to_validate="$1"
    
    # 1. Check for octet format (4 octets separated by dots)
    if [[ ! "$target_to_validate" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        return 1 # Wrong format
    fi
    
    # 2. Split the IP into four octets
    IFS='.' read -r octet1 octet2 octet3 octet4 <<< "$target_to_validate"
    
    # 3. Check if each octet is in valid range (0-255)
    if (( octet1 >= 0 && octet1 <= 255 )) && \
       (( octet2 >= 0 && octet2 <= 255 )) && \
       (( octet3 >= 0 && octet3 <= 255 )) && \
       (( octet4 >= 0 && octet4 <= 255 )); then
        return 0 # Validation successful
    else
        return 1 # Out of range (0-255) - one or more octets are incorrect
    fi
}

# --- MAIN SCRIPT ---

# Call glyph_welcome
glyph_welcome

ATTEMPTS=0
MAX_ATTEMPTS=2
TARGET=""
VALID_TARGET=false # Flag to track if we have a valid target

# --- 1. Check for command-line argument ($1) ---
if [ -n "$1" ]; then
    # If argument is provided, validate it immediately.
    TARGET=$1
    if glyph_validate_target "$TARGET"; then
        VALID_TARGET=true
    fi
else
    # --- 2. If no argument, enter the input loop. ---
    while [ "$VALID_TARGET" = false ] && [ $ATTEMPTS -le $MAX_ATTEMPTS ]; do # Note: <= for 3 attempts (0, 1, 2)
        # Display different prompts based on the attempt number.
        if [ $ATTEMPTS -eq 0 ]; then
            read -rp "Please enter the target coordinates for this mission, Commander: " TARGET
        else
            echo "-----------------------------------------------------------------------------------------------"
            echo "Warning: The provided coordinates are invalid. Please try again or the mission will be aborted."
            read -rp "Unable to establish a connection, Commander. Please verify the provided coordinates: " TARGET
        fi

        # Validate the target after reading input.
        if glyph_validate_target "$TARGET"; then
            VALID_TARGET=true # Set flag to true to exit the loop.
        fi

        ATTEMPTS=$((ATTEMPTS + 1))
    done
fi

# --- 3. Check if we have a valid target after all attempts. ---
if [ "$VALID_TARGET" = false ]; then
    echo "----------------------------------------------------------------------"
    echo "Maximum number of attempts reached. Critical failure. Aborting mission."
    exit 1
fi

# --- 4. Proceed with the mission using the validated TARGET. ---
echo "---------------------------------------------------"
echo "Establishing connection to $TARGET, Commander."
echo "Connection established. Proceeding with the mission..."

# --- 5. Generate TIMESTAMP and directory ---
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
OUTPUT_DIR="glyph-missionlog-$TARGET-$TIMESTAMP"
echo "--------------------------------------"
echo "The mission has begun at $TIMESTAMP..."

# Check and create OUTPUT_DIR
if [ ! -d "./$OUTPUT_DIR" ]; then
    mkdir -p "./$OUTPUT_DIR"
    echo "-----------------------------------------------------------------------------"
    echo "I've created the $OUTPUT_DIR directory to store your mission logs, Commander."
else
    echo "------------------------------------------------------------------"
    echo "Mission's logs are stored in the $OUTPUT_DIR directory, Commander!"
fi

echo "--------------------------------------------------"
echo "# Standing by for your next assignment, Commander."