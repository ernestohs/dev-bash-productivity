#!/bin/bash

# gum_ui.sh
# Interactive UI for dev-bash-productivity scripts using gum.

# Add local bin to PATH
export PATH="$PWD/bin:$PATH"

# Check for gum
if ! command -v gum >/dev/null 2>&1; then
    echo "Error: 'gum' is not installed or not in PATH."
    echo "Please run './setup_gum.sh' first."
    exit 1
fi

# Function to pause and return to menu
pause() {
    echo ""
    gum style --foreground 212 "Press any key to return to menu..."
    read -n 1 -s -r
}

# Header
show_header() {
    clear
    gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Dev Bash Productivity UI"
}

# --- Submenus ---

menu_backups() {
    BACKUP_OPT=$(gum choose "Backup Directory" "Main Menu")
    if [[ "$BACKUP_OPT" == "Backup Directory" ]]; then
        SRC=$(gum input --placeholder "Source Directory")
        DEST=$(gum input --placeholder "Backup Destination Directory")
        if [[ -n "$SRC" && -n "$DEST" ]]; then
            ./backupDir.sh "$SRC" "$DEST"
        fi
        pause
    fi
}

menu_git() {
    GIT_OPT=$(gum choose "Setup Git" "Commit" "Push" "Status" "Log" "Branch" "Main Menu")
    case "$GIT_OPT" in
        "Setup Git")
            EMAIL=$(gum input --placeholder "Email")
            NAME=$(gum input --placeholder "Name")
            ./git/setup_git.sh "$EMAIL" "$NAME"
            pause
            ;;
        "Commit")
            MSG=$(gum input --placeholder "Commit Message")
            ./git/commit.sh "$MSG"
            pause
            ;;
        "Push") ./git/push.sh; pause ;;
        "Status") ./git/status.sh; pause ;;
        "Log") ./git/log.sh; pause ;;
        "Branch") ./git/branch.sh; pause ;;
    esac
}

menu_network() {
    NET_OPT=$(gum choose "Check Port" "HTTP Status" "Main Menu")
    case "$NET_OPT" in
        "Check Port")
            HOST=$(gum input --placeholder "Host (e.g., google.com)")
            PORT=$(gum input --placeholder "Port (e.g., 80)")
            ./network/check-port-status.sh "$HOST" "$PORT"
            pause
            ;;
        "HTTP Status")
            URL=$(gum input --placeholder "URL (e.g., https://google.com)")
            ./network/monitor_http_status.sh "$URL"
            pause
            ;;
    esac
}

menu_node() {
    NODE_OPT=$(gum choose "Monitor Process" "Kill Process" "List Processes" "Main Menu")
    case "$NODE_OPT" in
        "Monitor Process")
            PROC=$(gum input --placeholder "Process Name")
            ./node/monitorProcess.sh "$PROC"
            pause
            ;;
        "Kill Process")
            PID=$(gum input --placeholder "PID")
            ./node/killProcess.sh "$PID"
            pause
            ;;
        "List Processes") ./node/listProcesses.sh; pause ;;
    esac
}

menu_python() {
    PY_OPT=$(gum choose "Setup Venv" "Run Script" "Boilerplate" "Main Menu")
    case "$PY_OPT" in
        "Setup Venv")
            DIR=$(gum input --placeholder "Project Directory")
            ./python/venv_setup.sh "$DIR"
            pause
            ;;
        "Run Script")
            SCRIPT=$(gum file . --height 10)
            if [[ -n "$SCRIPT" ]]; then
                ./python/run_script.sh "$SCRIPT"
            fi
            pause
            ;;
        "Boilerplate")
            ./python/boilerplate.sh
            pause
            ;;
    esac
}

menu_bulk() {
    BULK_OPT=$(gum choose "Bulk Rename" "Remove Word" "Main Menu")
    case "$BULK_OPT" in
        "Bulk Rename")
            DIR=$(gum input --placeholder "Directory")
            PATTERN=$(gum input --placeholder "Pattern (regex)")
            REPLACE=$(gum input --placeholder "Replacement")
            ./bulk/bulk_rename.sh "$DIR" "$PATTERN" "$REPLACE"
            pause
            ;;
        "Remove Word")
            WORD=$(gum input --placeholder "Word to remove")
            ./bulk/rmWord.sh "$WORD"
            pause
            ;;
    esac
}

menu_zombie() {
    ZOM_OPT=$(gum choose "Find Zombies" "Kill Zombies" "Main Menu")
    case "$ZOM_OPT" in
        "Find Zombies") ./zombie/findZombies.sh; pause ;;
        "Kill Zombies") ./zombie/killZombies.sh; pause ;;
    esac
}

menu_auto() {
    AUTO_OPT=$(gum choose "Organize Files" "Main Menu")
    case "$AUTO_OPT" in
        "Organize Files")
            DIR=$(gum input --placeholder "Directory to organize")
            ./auto/organize_files.sh "$DIR"
            pause
            ;;
    esac
}

# --- Main Loop ---

while true; do
    show_header
    CATEGORY=$(gum choose \
        "Backups" \
        "Git" \
        "Network" \
        "Node" \
        "Python" \
        "Bulk Info" \
        "Zombie Processes" \
        "Automation" \
        "Exit")

    case "$CATEGORY" in
        "Backups") menu_backups ;;
        "Git") menu_git ;;
        "Network") menu_network ;;
        "Node") menu_node ;;
        "Python") menu_python ;;
        "Bulk Info") menu_bulk ;;
        "Zombie Processes") menu_zombie ;;
        "Automation") menu_auto ;;
        "Exit") clear; exit 0 ;;
    esac
done
