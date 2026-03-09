#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SOURCE="$SCRIPT_DIR/skills"
RULES_SOURCE="$SCRIPT_DIR/rules"
CURSOR_SKILLS_DIR="$HOME/.cursor/skills"

show_list=false
with_rules=false
uninstall=false
selected_skills=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --list)       show_list=true; shift ;;
        --with-rules) with_rules=true; shift ;;
        --uninstall)  uninstall=true; shift ;;
        --skills)     selected_skills="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --list          Show available skills"
            echo "  --skills LIST   Comma-separated skills to install (e.g. sf-apex,sf-lwc)"
            echo "  --with-rules    Also install Cursor rules to .cursor/rules/"
            echo "  --uninstall     Remove all sf-* skills from ~/.cursor/skills/"
            echo "  -h, --help      Show this help"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

all_skills=($(ls -d "$SKILLS_SOURCE"/sf-* 2>/dev/null | xargs -n1 basename | sort))

if $show_list; then
    echo ""
    echo "Available Salesforce Skills (${#all_skills[@]}):"
    echo "--------------------------------------------------"
    for skill in "${all_skills[@]}"; do
        skill_file="$SKILLS_SOURCE/$skill/SKILL.md"
        if [[ -f "$skill_file" ]]; then
            desc=$(awk '/^description:/{flag=1; sub(/^description: */, ""); print; next} flag && /^---/{exit} flag{print}' "$skill_file" | head -1 | cut -c1-80)
        else
            desc="(no SKILL.md yet)"
        fi
        printf "  \033[32m%-35s\033[0m %s\n" "$skill" "$desc"
    done
    echo ""
    exit 0
fi

if $uninstall; then
    echo ""
    echo "Uninstalling Salesforce skills..."
    removed=0
    for skill in "${all_skills[@]}"; do
        target="$CURSOR_SKILLS_DIR/$skill"
        if [[ -d "$target" ]]; then
            rm -rf "$target"
            echo "  Removed: $skill"
            ((removed++))
        fi
    done
    if [[ $removed -eq 0 ]]; then
        echo "  No skills found to remove."
    else
        echo ""
        echo "Removed $removed skill(s). Restart Cursor to apply."
    fi
    exit 0
fi

skills_to_install=("${all_skills[@]}")
if [[ -n "$selected_skills" ]]; then
    IFS=',' read -ra skills_to_install <<< "$selected_skills"
    for s in "${skills_to_install[@]}"; do
        s=$(echo "$s" | xargs)
        if [[ ! " ${all_skills[*]} " =~ " $s " ]]; then
            echo "Unknown skill: $s"
            echo "Run $0 --list to see available skills."
            exit 1
        fi
    done
fi

mkdir -p "$CURSOR_SKILLS_DIR"

echo ""
echo "Installing ${#skills_to_install[@]} Salesforce skill(s) to $CURSOR_SKILLS_DIR ..."
installed=0
for skill in "${skills_to_install[@]}"; do
    skill=$(echo "$skill" | xargs)
    source_dir="$SKILLS_SOURCE/$skill"
    target_dir="$CURSOR_SKILLS_DIR/$skill"

    rm -rf "$target_dir"
    cp -r "$source_dir" "$target_dir"
    echo "  Installed: $skill"
    ((installed++))
done

if $with_rules; then
    project_rules_dir="$(pwd)/.cursor/rules"
    mkdir -p "$project_rules_dir"
    echo ""
    echo "Copying Cursor rules to $project_rules_dir ..."
    for rule in "$RULES_SOURCE"/*.mdc; do
        [[ -f "$rule" ]] || continue
        cp "$rule" "$project_rules_dir/"
        echo "  Installed: $(basename "$rule")"
    done
fi

echo ""
echo "Done! Installed $installed skill(s). Restart Cursor to apply."
echo ""
