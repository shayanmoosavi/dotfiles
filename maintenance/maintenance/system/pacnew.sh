#!/bin/bash


# Find all .pacnew and .pacsave files
find_pacnew_files() {
    sudo find /etc -name "*.pacnew" -o -name "*.pacsave" 2>/dev/null | sort
}

# Count pacnew/pacsave files
count_pacnew_files() {
    find_pacnew_files | wc -l
}

# Display summary of files
display_pacnew_summary() {
    local -a files=()

    while IFS= read -r file; do
        files+=("$file")
    done < <(find_pacnew_files)

    if [[ ${#files[@]} -eq 0 ]]; then
        print_success "No .pacnew or .pacsave files found!"
        return 1
    fi

    echo ""
    echo -e "${BOLD}Found ${#files[@]} .pacnew/.pacsave file(s):${NC}"
    echo ""

    for file in "${files[@]}"; do
        # Get file type and original file
        if [[ "$file" =~ \.pacnew$ ]]; then
            local original="${file%.pacnew}"
            local type="pacnew"
        else
            local original="${file%.pacsave}"
            local type="pacsave"
        fi

        # Check if original exists
        if [[ -f "$original" ]]; then
            echo "  [$type] $file"
        else
            echo "  [$type] $file ${YELLOW}(original missing)${NC}"
        fi
    done

    echo ""
    return 0
}

# Check if meld is available
has_meld() {
    command -v meld &>/dev/null
}

# Check if pacdiff is available
has_pacdiff() {
    command -v pacdiff &>/dev/null
}

# Get preferred merge tool
get_merge_tool() {
    # Auto-detect: prefer meld if available, fallback to pacdiff
    if has_meld; then
        echo "meld"
    elif has_pacdiff; then
        echo "pacdiff"
    else
        echo "none"
    fi
}

# Run pacdiff with optional meld integration
run_pacdiff() {
    local merge_tool
    merge_tool=$(get_merge_tool)

    if [[ "$merge_tool" == "none" ]]; then
        print_error "Neither pacdiff nor meld is installed"
        print_info "Install with: sudo pacman -S pacman-contrib meld"
        return 1
    fi

    print_info "Starting pacnew review with $merge_tool"

    if [[ "$merge_tool" == "meld" ]]; then
        # Set environment variable for pacdiff to use meld
        export DIFFPROG="meld"
        print_info "Launching pacdiff with meld for visual merging..."
    else
        print_info "Launching pacdiff for interactive review..."
    fi

    echo ""

    # Run pacdiff interactively
    # It will handle all the merging logic
    if sudo -E pacdiff; then
        print_success "Pacnew review completed successfully"
        return 0
    else
        local exit_code=$?

        # Exit code 0 = success
        # Exit code 1 = user quit
        # Other = error

        if [[ $exit_code -eq 1 ]]; then
            print_info "Review cancelled by user"
            return 0
        else
            print_error "Pacdiff exited with error code: $exit_code"
            return 1
        fi
    fi
}

# Main pacnew review function
review_pacnew_files() {
    print_info "Checking for .pacnew and .pacsave files..."
    print_info "========== Pacnew review started =========="

    # Check dependencies
    if ! has_pacdiff; then
        print_error "pacdiff is not installed (part of pacman-contrib)"
        print_info "Install with: sudo pacman -S pacman-contrib"
        return 1
    fi

    # Display summary
    if ! display_pacnew_summary; then
        print_info "No pacnew/pacsave files found"
        print_info "========== Pacnew review completed =========="
        return 0
    fi

    # Log which tool will be used
    local merge_tool
    merge_tool=$(get_merge_tool)

    if [[ "$merge_tool" == "meld" ]]; then
        print_success "Meld detected - will use visual merge interface"
        print_info "Using meld for merging"
    else
        print_info "Using pacdiff default merge tool"
        print_info "Using pacdiff default"
    fi

    echo ""
    echo "Pacdiff will guide you through reviewing each file"
    echo "For each file, you can:"
    echo "  - View the differences"
    echo "  - Edit and merge changes"
    echo "  - Keep the new file"
    echo "  - Keep the old file"
    echo "  - Skip for now"
    echo ""

    read -rp "Start pacnew review? (y/N): " start_review

    if [[ ! "$start_review" =~ ^[Yy]$ ]]; then
        print_info "Review cancelled"
        print_info "User chose not to start review"
        print_info "========== Pacnew review completed =========="
        return 0
    fi

    # Run the review
    run_pacdiff
    local review_result=$?

    echo ""

    # Check if any files remain
    local remaining
    remaining=$(count_pacnew_files)

    if [[ $remaining -eq 0 ]]; then
        print_success "All .pacnew/.pacsave files have been reviewed!"
    else
        print_info "$remaining .pacnew/.pacsave file(s) remaining"
    fi

    print_info "========== Pacnew review completed =========="

    return $review_result
}
