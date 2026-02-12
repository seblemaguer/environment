#!/bin/zsh

# Set environment path to the current directory
PLUGIN_PATH=/home/lemaguer/environment/local/apps/gradle-org-export-plugin
NB_PROC=1

# Dealing with options
while getopts ":j:dinMhsV" opt; do
    case $opt in
        j)
            NB_PROC=$OPTARG
            ;;
        d)
            DEBUG_MODE=true
            ;;
        i)
            INFO_MODE=true
            ;;
        M)
            WITHOUT_MULTIMEDIA=true
            ;;
        n)
            WITH_NOTES=true
            ;;
        s)
            STACKTRACE_MODE=true
            ;;
        V)
            WITHOUT_VIDEO=true
            ;;
        h)
            HELP_MODE=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            ;;
    esac
done
shift $OPTIND-1

# Dealing with arguments
if [[ $# -lt 1 ]]; then
    echo "$0 [[-j <nb_proc>]] [[-s]] [[-i]] [[-d]] <export_type>"

    # Default modes
    echo "  -j parallel mode (if nb_proc is 0, use all the processor, else use the given number of workers)"
    echo "  -d activate gradle debug mode"
    echo "  -i activate gradle info mode"
    echo "  -s activate gradle stack mode"

    echo "  -n insert note slides"
    echo "  -M *DISABLE* multimedia assets"
    echo "  -V *DISABLE* videos assets"

    if [[ "$HELP_MODE" == true ]]; then
        exit 0
    else
        exit -1
    fi
fi
EXPORT_TASK=$1

# Control number of workers
PARALLEL_OPT=(--max-workers 1)
if [[ $NB_PROC -eq 0 ]]; then
    PARALLEL_OPT=""
elif [[ $NB_PROC -gt 1 ]]; then
    PARALLEL_OPT=(--max-workers $NB_PROC)
fi

# Define verbosity and debugging options
[[ "$DEBUG_MODE" == true ]] && DEBUG_OPT="--debug"
[[ "$INFO_MODE" == true ]] && INFO_OPT="--info"
[[ "$WITH_NOTES" == true ]] && WITH_NOTES_OPT="-Pwith_notes=TRUE"
[[ "$WITHOUT_MULTIMEDIA" == true ]] && WITHOUT_MULTIMEDIA_OPT="-Pwithout_multimedia=TRUE"
[[ "$WITHOUT_VIDEO" == true ]] && WITHOUT_VIDEO_OPT="-Pwithout_video=TRUE"
[[ "$STACKTRACE_MODE" == true ]] && STACKTRACE_OPT="--stacktrace"

# Ready to run the command now
./gradlew --include-build="$PLUGIN_PATH" $DEBUG_OPT $WITH_NOTES_OPT $PARALLEL_OPT $INFO_OPT $STACKTRACE_OPT $EXPORT_TASK
