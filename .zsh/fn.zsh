open() {
  unameOut="$(uname -s)"
  case "${unameOut}" in
  Linux*) nohup xdg-open "${@:-.}" >/dev/null 2>&1 & ;;
  Darwin*) command open "$@" ;;
  *) fail "Unsupported OS: ${unameOut}" ;;
  esac
}
