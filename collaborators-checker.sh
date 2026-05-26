#!/bin/bash

# Script to fetch all collaborators from all your repositories
# Requirements: GitHub CLI (gh) installed and authenticated
# Install: https://cli.github.com/

echo "🔍 Fetching all collaborators from your repositories..."
echo "=================================================="

# Get the current user
CURRENT_USER=$(gh auth status --show-token 2>/dev/null | grep "Logged in to" | awk '{print $NF}' || gh api user -q '.login')

# Create output file
OUTPUT_FILE="collaborators_report_$(date +%Y%m%d_%H%M%S).txt"

{
    echo "Collaborators Report for User: $CURRENT_USER"
    echo "Generated: $(date)"
    echo "=================================================="
    echo ""
} > "$OUTPUT_FILE"

# Get all repos with their collaborators
gh repo list "$CURRENT_USER" --limit 1000 --json name,owner -q '.[].name' | while read repo; do
    echo "Checking: $repo..."
    
    # Get collaborators for this repo
    COLLABORATORS=$(gh api -H "Accept: application/vnd.github.v3+json" "repos/$CURRENT_USER/$repo/collaborators" -q '.[].login' 2>/dev/null)
    
    if [ -z "$COLLABORATORS" ]; then
        # No collaborators or repo is private/inaccessible
        echo "  ├─ No collaborators" >> "$OUTPUT_FILE"
    else
        echo "  ├─ $repo:" >> "$OUTPUT_FILE"
        echo "$COLLABORATORS" | while read collab; do
            echo "  │  └─ $collab" >> "$OUTPUT_FILE"
        done
    fi
    
    echo "$repo" >> "$OUTPUT_FILE"
    echo "$COLLABORATORS" >> "$OUTPUT_FILE"
    echo "---" >> "$OUTPUT_FILE"
done

echo ""
echo "✅ Report saved to: $OUTPUT_FILE"
echo "=================================================="
cat "$OUTPUT_FILE"
