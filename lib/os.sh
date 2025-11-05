detect_os() {
  case "$(uname -s)" in
    Darwin*) echo "macos" ;;
    Linux*) echo "linux" ;;
    *) echo "unknown" ;;
  esac
}
