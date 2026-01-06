#!/bin/zsh

HELP="$0 [-r] <remote ID>"
ROOT_DIR=/media/lemaguer/LEMAGUES_WORK/backups/

# Dealing with options
while getopts ":hr" opt; do
    case $opt in
        r)
            IS_REMOTE=true
            echo "parallel mode activated with $NB_PROC process" >&2
            ;;
        h)
            echo $HELP
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit -1
            ;;
    esac
done
shift $OPTIND-1

if [ $# -ne 1 ]; then
    echo $HELP
    exit -1
fi

REMOTE=$1
if [ "$IS_REMOTE" != true ]
then
    ATOMIC_NAME=$(basename $1)
else
    ATOMIC_NAME=$REMOTE
fi
REPO=$ROOT_DIR/$ATOMIC_NAME

# Initialize repository if it doesn't exist
if [ ! -d "$REPO/snapshots" ]; then
    echo "Initializing Borg repository at $REPO/snapshots"
    mkdir -p "$REPO"
    borg init --encryption=none "$REPO/snapshots"
    cat<<EOF > $REPO/ignore.txt
# Caches and temporary files
cache/
tmp/
*.tmp

# Log files
*.log
logs/

# Version control directories
.git/
.hg/
.svn/

# System files
.DS_Store
Thumbs.db

# Backups or archives inside the website folder
*.bak
*.zip
*.tar.gz
EOF
fi

# Step 1: Update local copy

if [ "$IS_REMOTE" != true ]
then
    rsync -aviz --delete $REMOTE/ $REPO/current_state/
else
    rsync -aviz --delete $REMOTE:./ $REPO/current_state/
fi

# Step 2: Backup with Borg
borg create \
     --stats --compression zstd,6 \
     --exclude-from $REPO/ignore.txt \
     $REPO/snapshots::$ATOMIC_NAME-$(date +"%F_%R") $REPO/current_state

# Step 3: Prune old backups
borg prune -v --list $REPO/snapshots \
  --keep-daily=7 --keep-weekly=4 --keep-monthly=12 --keep-yearly=5
