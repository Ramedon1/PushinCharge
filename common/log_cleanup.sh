#!/system/bin/sh
# PushinCharge Log Cleaner
# This script helps manage log files created by the module

LOGDIR=/data/local/tmp/PushinCharge

mkdir -p $LOGDIR

# Usage function
usage() {
  echo "PushinCharge Log Cleaner"
  echo "Usage: $0 [option]"
  echo ""
  echo "Available options:"
  echo "  clean     - Clean all logs but keep current session"
  echo "  purge     - Remove all logs completely"
  echo "  status    - Show log file sizes and locations"
  echo ""
  echo "Example: $0 clean"
}

clean_logs() {
  if [ -f "$LOGDIR/charging_log.txt" ]; then
    cp "$LOGDIR/charging_log.txt" "$LOGDIR/charging_log_backup.txt"
  fi
  
  echo "$(date) - Log cleanup requested" > "$LOGDIR/charging_log.txt"
  
  echo "$(date) - Log cleared" > "$LOGDIR/manual_switch.txt"
  echo "$(date) - Log cleared" > "$LOGDIR/compatibility_check.txt"
  
  if [ -f "$LOGDIR/charging_log_backup.txt" ]; then
    echo "" >> "$LOGDIR/charging_log.txt"
    echo "--- Previous session info ---" >> "$LOGDIR/charging_log.txt"
    tail -n 10 "$LOGDIR/charging_log_backup.txt" >> "$LOGDIR/charging_log.txt"
    rm "$LOGDIR/charging_log_backup.txt"
  fi
  
  echo "Logs have been cleaned. Current session information preserved."
}

purge_logs() {
  rm -f "$LOGDIR"/*.txt
  
  echo "$(date) - All logs purged" > "$LOGDIR/charging_log.txt"
  
  echo "All logs have been purged."
}

show_status() {
  echo "PushinCharge Log Status"
  echo "======================="
  echo "Log directory: $LOGDIR"
  echo ""
  
  echo "Log Files:"
  for logfile in "$LOGDIR"/*.txt; do
    if [ -f "$logfile" ]; then
      filesize=$(wc -c < "$logfile")
      filename=$(basename "$logfile")
      echo "- $filename: $filesize bytes"
    fi
  done
  
  totalsize=$(du -ch "$LOGDIR"/*.txt 2>/dev/null | grep total | cut -f1)
  echo ""
  echo "Total log size: $totalsize"
  echo ""
  
  if [ $(du -k "$LOGDIR" | cut -f1) -gt 1024 ]; then
    echo "Recommendation: Logs are getting large. Consider running 'clean' or 'purge'."
  else
    echo "Recommendation: Log size is reasonable. No action needed."
  fi
}

case "$1" in
  "clean")
    clean_logs
    ;;
  "purge")
    purge_logs
    ;;
  "status")
    show_status
    ;;
  *)
    usage
    ;;
esac
