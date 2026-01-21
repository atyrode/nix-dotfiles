############################################
# Utils
############################################

prompt_yes_no() {
  local prompt_message=$1
  local answer
  while true; do
    echo -n "$prompt_message (y/n): "
    read answer
    case $answer in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}
