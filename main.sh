#!/bin/bash

# Option to delete all existing patterns
read -p "Do you want to delete all existing patterns in the 'patterns' folder? (y/N) " delete_choice
if [[ "$delete_choice" =~ ^[Yy]$ ]]; then
    echo -e "⚠️  This will permanently delete all CSV files in 'patterns/'."
    read -p "❓  Are you absolutely sure? Type 'yes' to confirm: " confirm_delete
    
    if [[ "$confirm_delete" == "yes" ]]; then
        rm -f patterns/*.csv
        echo -e "🗑️  All pattern files have been deleted.\n\n"
        elif [[ -z "$confirm_delete" ]]; then
        echo -e "❌ Deletion canceled (no input).\n\n"
    else
        echo -e "❌ Invalid input: \"$confirm_delete\". Deletion aborted.\n\n"
    fi
else
    echo -e "ℹ️  Deletion skipped.\n\n"
fi

read -p "Do you want to quit? (y/N) :"

if [[ "$choice" =~ ^[Cc]$ ]]; then
    echo "🛑 Bye."
    rm -f "$target_file"
    exit 1
else
    echo -e "▶️  You chose to continue with the pattern creation.\n\n"
fi

# Create patterns directory if it doesn't exist
mkdir -p patterns
# Welcome message
echo -e "🧶 Put together your crochet pattern 🧵\n"

# Target file
read -p "Name of your new little friend: " name
target_file="patterns/${name// /_}_pattern.csv"
touch "$target_file"



# Part selection function
function addPart() {
    type=$1
    type_lowercase="${type,,}"
    folder="parts"
    
    echo ""
    case "$type_lowercase" in
        head) symbol="🧠" ;;
        ears) symbol="👂" ;;
        nose) symbol="👃" ;;
        arms) symbol="💪" ;;
        body) symbol="🧸" ;;
        legs) symbol="🦵" ;;
        tail) symbol="🐾" ;;
        *) symbol="🔸" ;;
    esac
    
    echo "$symbol Available $type:"
    echo "Looking for files in: $folder/${type_lowercase}/*.csv"
    parts=($folder/${type_lowercase}/*.csv)
    echo "Found files: ${#parts[@]}"
    
    for i in "${!parts[@]}"; do
        echo "$((i+1))) $(basename "${parts[$i]}")"
    done
    
    while true; do
        echo ""
        read -p "Which $type do you want to use? (Number, s = Skip, c = Cancel) " choice
        
        if [[ "$choice" =~ ^[Cc]$ ]]; then
            echo "🛑 Canceled. No pattern created."
            rm -f "$target_file"
            exit 1
        fi
        
        if [[ "$choice" =~ ^[Ss]$ ]]; then
            echo "⏭️  Skipped $type."
            break
        fi
        
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            index=$((choice-1))
            if [[ $index -ge 0 && $index -lt ${#parts[@]} ]]; then
                file="${parts[$index]}"
                filename=$(basename "$file")
                
                content=$(sed '1 s/^\xEF\xBB\xBF//' "$file" | \
                    sed 's/"/""/g' | \
                    sed -E 's/;\(?-?([0-9]+)\)?$/;="(\1)"/'
                )
                
                echo "$content" >> "$target_file"
                echo -e "💾 Saved \"$filename\" to pattern."
                break
            else
                echo "❌ Invalid number. Please choose a valid part."
            fi
        else
            echo "❌ Invalid input. Enter a number, 's' to skip, or 'c' to cancel."
        fi
    done
}

# Choose parts
addPart "head"
addPart "ears"
addPart "nose"
addPart "arms"
addPart "body"
addPart "legs"
addPart "tail"

echo -e "\n✅ Your pattern has been saved to: $target_file\n"

# Open the pattern
echo -e "📖 Opening your pattern in Excel...\n"

case "$OSTYPE" in
    linux*)   libreoffice --calc "$target_file" & ;;
    darwin*)  open -a "Microsoft Excel" "$target_file" ;;
    msys*|cygwin*)  start excel.exe "$target_file" ;;
    *)        echo "⚠️ Your operating system is not supported. Please open the file manually: $target_file" ;;
esac
