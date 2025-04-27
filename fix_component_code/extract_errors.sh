
#!/bin/bash

#Error extraction script: extract_errors.sh
#Usage: extract_orrors.sh<log file><output file>

logfile="$1"
output_file="$2"

> "$output_file"

echo "Processing file: $logfile" >> "$output_file"
echo "----------------------------------------" >> "$output_file"

# Check if the log contains Error-[CNST-CIF]
if grep -q "Error-\[CNST-CIF\]" "$logfile"; then
    awk '
    BEGIN {
        in_solver_block = 0
        in_error_block = 0
        solver_start = 0
        print_count = 0
    }
    
    /=======================================================/ {
        if (in_solver_block == 0 && !in_error_block) {
            solver_start = NR
        }
        else if (in_solver_block == 1) {
            print $0
            in_solver_block = 2  
        }
    }
    
    /Solver failed when solving following set of constraints/ && solver_start > 0 {
        in_solver_block = 1
        for (i = solver_start; i <= NR; i++) {
            print saved_lines[i]
        }
        next
    }
    
    in_solver_block == 1 {
        print $0
    }
    
    /Error-\[CNST-CIF\]/ && in_solver_block == 2 {
        in_error_block = 1
        print ""
        print $0
        next
    }
    
    in_error_block == 1 {
        if (NF == 0) {
            exit
        }
        print $0
    }
    
    {
        saved_lines[NR] = $0
    }
    ' "$logfile" >> "$output_file"
else
    awk '/Error/,/^$/' "$logfile" >> "$output_file"
fi

echo "" >> "$output_file"
