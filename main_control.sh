
#!/bin/bash



# Step 1: Run the initial_tb script
./initial_tb.sh

# Step 2: Check if the tb succeeded
if [ -f simulation_success.txt ]; then
    echo "Pre-coverage script completed successfully. Proceeding to coverage collection."
    bash ./increase_seq.sh
else
    echo "increase coverage script failed. Exiting."
    exit 1
fi
