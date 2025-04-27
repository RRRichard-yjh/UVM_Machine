
#!/usr/bin/bash


# Read and process scores from extracted_coverage_data.txt
while IFS= read -r line; do
    line_score=$(echo "$line" | grep -oP '(?<=LINE:)\d+\.\d+')
    cond_score=$(echo "$line" | grep -oP '(?<=COND:)\d+\.\d+')
    toggle_score=$(echo "$line" | grep -oP '(?<=TOGGLE:)\d+\.\d+')
    fsm_score=$(echo "$line" | grep -oP '(?<=FSM:)\d+\.\d+')
    branch_score=$(echo "$line" | grep -oP '(?<=BRANCH:)\d+\.\d+')

        if [ -z "$line_score" ]; then
            echo "No coverage of this type: LINE"
        else
            if (( $(echo "$line_score <= 95" | bc -l) )); then
                if [ -f "./auto_coverage/uncovered_code/line_coverage.txt" ]; then
                    python3 ./auto_add_seq/code/line/gpt4o_add_line_code_seq_old.py
                else
                    echo "line_coverage.txt file not found"
                fi
            else
                echo "Line coverage rate is high, reaching over 95%."
            fi
        fi

        # Check conditional coverage
        if [ -z "$cond_score" ]; then
            echo "No coverage of this type: COND"
        else
            if (( $(echo "$cond_score <= 95" | bc -l) )); then
                if [ -f "./auto_coverage/uncovered_code/conditional_coverage.txt" ]; then
                    python3 ./auto_add_seq/code/cond/gpt4o_add_cond_code_seq_old.py
                else
                    echo "conditional_coverage.txt file not found"
                fi
            else
                echo "Conditional coverage rate is high, reaching over 95%."
            fi
        fi

        # Check toggle coverage
        if [ -z "$toggle_score" ]; then
            echo "No coverage of this type: TOGGLE"
        else
            if (( $(echo "$toggle_score <= 95" | bc -l) )); then
                if [ -f "./auto_coverage/uncovered_code/toggle_coverage.txt" ]; then
                    python3 ./auto_add_seq/code/toggle/gpt4o_add_toggle_code_seq_old.py
                else
                    echo "toggle_coverage.txt file not found"
                fi
            else
                echo "Toggle coverage rate is high, reaching over 95%."
            fi
        fi

        # Check FSM coverage
        if [ -z "$fsm_score" ]; then
            echo "No coverage of this type: FSM"
        else
            if (( $(echo "$fsm_score <= 95" | bc -l) )); then
                if [ -f "./auto_coverage/uncovered_code/fsm_coverage.txt" ]; then
                    python3 ./auto_add_seq/code/gpt4o_add_fsm_code_seq_old.py
                else
                    echo "fsm_coverage.txt file not found"
                fi
            else
                echo "FSM coverage rate is high, reaching over 95%."
            fi
        fi

        # Check branch coverage
        if [ -z "$branch_score" ]; then
            echo "No coverage of this type: BRANCH"
        else
            if (( $(echo "$branch_score <= 95" | bc -l) )); then
                if [ -f "./auto_coverage/uncovered_code/branch_coverage.txt" ]; then
                    python3 ./auto_add_seq/code/branch/gpt4o_add_branch_code_seq_old.py
                else
                    echo "branch_coverage.txt file not found"
                fi
            else
                echo "Branch coverage rate is high, reaching over 95%."
            fi
        fi
	break
done < ./auto_coverage/extracted_coverage_data.txt

