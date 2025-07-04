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
    
    # Check for octet format (4 octets separated by dots)
    if [[ ! "$target_to_validate" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        return 1 # Wrong format
    fi
    
    # Split the IP into four octets
    IFS='.' read -r octet1 octet2 octet3 octet4 <<< "$target_to_validate"
    
    # Check if each octet is in valid range (0-255)
    if (( octet1 >= 0 && octet1 <= 255 )) && \
       (( octet2 >= 0 && octet2 <= 255 )) && \
       (( octet3 >= 0 && octet3 <= 255 )) && \
       (( octet4 >= 0 && octet4 <= 255 )); then
        return 0 # Validation successful
    else
        return 1 # Out of range (0-255) - one or more octets are incorrect
    fi
}

# Glyph's recon Nmap function
glyph_recon_nmap () {
    local target_to_scan="$1"
    local output_dir="$2"

    # Glyph's scan initial message
    echo "--------------------------------------------------------------------"
    echo "Initializing basic reconnaissance scan on $target_to_scan, Commander."
    echo "This will include host discovery and top 1000 TCP ports scan."

    # Glyph's additional scan configuration
    echo "--------------------------------------------------------------------"
    echo "Commander, you can enhance this scan with additional options."
    echo "You also have the capability to perform advanced reconnaissance with UDP scan, Commander."

    local nmap_options=""

    # Option: service version detection (-sV)
    read -rp "Add Service Version Detection (-sV)? (Provides detailed info about running services, e.g., Apache 2.4.52): [y/N] " CHOICE
    if [[ "$CHOICE" =~ ^[yY]$ ]]; then
        nmap_options+=" -sV"
    fi
    
    # Option: OS detection (-O)
    read -rp "Add OS Detection (-O)? (Attempts to identify the target's operating system, e.g., Linux 5.x): [y/N] " CHOICE
    if [[ "$CHOICE" =~ ^[yY]$ ]]; then
        nmap_options+=" -O"
    fi

    # Option: use default Nmap scripts (-sC)
    read -rp "Run Default Nmap Scripts (-sC)? (Automates common vulnerability checks and info gathering, may be noisy): [y/N] " CHOICE
    if [[ "$CHOICE" =~ ^[yY]$ ]]; then
        nmap_options+=" -sC"
    fi

    # Option: Aggressive Timing (--T4)
    read -rp "Use Aggressive Timing (--T4)? (Speeds up scan, but may be detected more easily): [y/N] " CHOICE
    if [[ "$CHOICE" =~ ^[yY]$ ]]; then
        nmap_options+=" --T4"
    fi

    # Option: show only open ports (--open)
    read -rp "Show Only Open Ports (--open)? (Filters results to only display open ports, ignoring closed/filtered): [y/N] " CHOICE
    if [[ "$CHOICE" =~ ^[yY]$ ]]; then
        nmap_options+=" --open"
    fi

    # Option: enable very verbose output (-vv)
    read -rp "Enable Very Verbose Output (-vv)? (Displays more detailed scan information during execution): [y/N] " CHOICE
    if [[ "$CHOICE" =~ ^[yY]$ ]]; then
        nmap_options+=" -vv"
    fi

    # Option: UDP Scan (-sU)
    read -rp "Run UDP Scan (-sU)? (Scans top 1000 UDP ports. CAUTION, Commander: This process will be significantly slower than TCP-only scans): [y/N] " CHOICE
    if [[ "$CHOICE" =~ ^[yY]$ ]]; then
        nmap_options+=" -sU"
    fi

    # Glyph's acknowledge 
    echo "---------------------------------------------------------------"
    echo "Preparing to begin recon scan with chosen options, Commander..."

    # Define output file base name
    local output_file_base="$output_dir/nmap_scan" 

    # Submitting the command
    nmap -sS -Pn $nmap_options "$target_to_scan" -oA "$output_file_base"

    # Checking the exit status of the Nmap command
    if [ $? -ne 0 ]; then
        echo "CRITICAL FAILURE: Recon scan for $target_to_scan encountered an error. Check logs in $output_dir for details, Commander." >&2 # Redirect to stream number 2 (stderr)
        return 1 # Function error
    fi

    # Inform scan completion
    echo "--------------------------------------------------------------------------------"
    # Informing the user about all generated files using a wildcard
    echo "Reconnaissance scan completed, Commander. Results stored in: ${output_file_base}.*"

    # Enumerate generated files
    echo "--------------------------------------------------------------------------------"
    echo "Commander, we have successfully gathered the following intelligence data:"
    ls -lh "${output_file_base}".*
    echo "--------------------------------------------------------------------------------"
    echo "Awaiting further instructions, Commander."
}

# Glyph's interrupt handler function
glyph_interrupt_handler () {
    echo "" # Prevent Glyph's output from being corrupted by the Ctrl+C signal.
    echo "--------------------------------------------------------------------------------"
    echo "Commander, mission has been aborted upon your request (Ctrl+C received)."
    echo "Shutting down reconnaissance protocols. Standing by for further orders."
    echo "--------------------------------------------------------------------------------"
    exit 1
}


# --- MAIN SCRIPT ---

# Call glyph_welcome
glyph_welcome

# Call glyph_interrupt_handler (Ctrl+C (SIGINT))
trap glyph_interrupt_handler SIGINT

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

# --- 6. Check and create OUTPUT_DIR ---
if [ ! -d "./$OUTPUT_DIR" ]; then
    mkdir -p "./$OUTPUT_DIR"
    echo "-----------------------------------------------------------------------------"
    echo "I've created the $OUTPUT_DIR directory to store your mission logs, Commander."
else
    echo "------------------------------------------------------------------"
    echo "Mission's logs are stored in the $OUTPUT_DIR directory, Commander!"
fi

# Call glyph_recon_nmap function
if ! glyph_recon_nmap "$TARGET" "$OUTPUT_DIR"; then
    echo "----------------------------------------------------------------------"
    echo "Major reconnaissance task failed. Aborting mission, Commander." >&2 # Redirect to stream number 2 (stderr)
    exit 1
fi

echo "--------------------------------------------------"
echo "# Standing by for your next assignment, Commander."