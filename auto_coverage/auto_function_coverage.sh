
#!/bin/bash

if [[ ! -s ./auto_coverage/uncovered_bins.txt ]]; then
    echo "File is empty."
    exit 1
fi

last_line=$(tail -n 1 ./auto_coverage/uncovered_bins.txt)

value=$(echo "$last_line" | sed -n 's/.*\([0-9]\+\.[0-9]\+\).*/\1/p')

if [[ -z "$value" ]]; then
    echo "No valid value found in the last line."
    exit 1
fi

if (( $(echo "$value <= 95" | bc -l) )); then
    /Soft/anaconda3_2024/bin/python3.11 ./auto_add_seq/function/gpt4o_add_func_seq_old.py
else
    echo "The function coverage rate is high, reaching over 95%."
fi




