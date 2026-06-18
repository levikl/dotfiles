// logical-space — compute hotkey labels for spaces across a multi-monitor setup,
// independent of macOS's global space numbering.
//
// macOS numbers spaces globally in display-arrangement (row-major) order, which
// on this machine is ultrawide -> external -> macbook. This tool defines its own
// labeling in two zones:
//   - Front  (ultrawide -> macbook -> any other display): ascending 1, 2, 3, ...
//   - Anchor (second external): descending from 10 (oldest space = 10, each
//     newer one takes the next lower number: 9, 8, ...).
//
// It reads live yabai state, so labels track spaces being created/destroyed.
// This is a compiled replacement for the old logical-space.sh: same constants,
// same scheme, same output, but one `yabai -m query` and no jq/bash spawns.
//
// Usage:
//   logical-space --focus <label>   focus the space with that hotkey label
//   logical-space --move  <label>   move window to that space, then follow
//   logical-space --map             print "<label> <global-space-index>" lines

#include <nlohmann/json.hpp>

#include <spawn.h>
#include <sys/wait.h>
#include <unistd.h>

#include <algorithm>
#include <array>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

extern char **environ;

using json = nlohmann::json;

// Front display order, by stable display UUID.
static const std::array<const char *, 2> kFrontOrder = {
    "38826603-725F-4024-A18F-9435EF5F12A8", // ultrawide
    "37D8832A-2D66-02CA-B9F7-8F30A301B230", // macbook built-in
};
// Anchor display: labeled descending from kAnchorStart.
static const char *kAnchorUuid = "F85610BA-380C-4572-BCAB-2D3FF65FF22D"; // external
static const int kAnchorStart = 10;

// Resolve the yabai binary: PATH works in the skhd/sketchybar contexts, but fall
// back to the common Homebrew location so the helper is robust to a bare PATH.
static const char *yabai_bin() {
  if (access("/opt/homebrew/bin/yabai", X_OK) == 0) return "/opt/homebrew/bin/yabai";
  if (access("/usr/local/bin/yabai", X_OK) == 0) return "/usr/local/bin/yabai";
  return "yabai"; // let PATH resolve it
}

// Spawn argv (NULL-terminated) without a shell, optionally capturing stdout.
// Returns the child's exit status, or -1 on spawn failure.
static int run(char *const argv[], std::string *out) {
  int pipefd[2];
  posix_spawn_file_actions_t fa;
  posix_spawn_file_actions_init(&fa);

  if (out) {
    if (pipe(pipefd) != 0) {
      posix_spawn_file_actions_destroy(&fa);
      return -1;
    }
    posix_spawn_file_actions_adddup2(&fa, pipefd[1], STDOUT_FILENO);
    posix_spawn_file_actions_addclose(&fa, pipefd[0]);
    posix_spawn_file_actions_addclose(&fa, pipefd[1]);
  }

  pid_t pid;
  int rc = posix_spawnp(&pid, argv[0], &fa, nullptr, argv, environ);
  posix_spawn_file_actions_destroy(&fa);
  if (rc != 0) {
    if (out) { close(pipefd[0]); close(pipefd[1]); }
    return -1;
  }

  if (out) {
    close(pipefd[1]);
    char buf[4096];
    ssize_t n;
    while ((n = read(pipefd[0], buf, sizeof(buf))) > 0) out->append(buf, n);
    close(pipefd[0]);
  }

  int status = 0;
  waitpid(pid, &status, 0);
  return WIFEXITED(status) ? WEXITSTATUS(status) : -1;
}

// Query `yabai -m query --displays` and parse it. Returns false on any failure.
static bool query_displays(json &out) {
  std::string raw;
  const char *yabai = yabai_bin();
  char *const argv[] = {const_cast<char *>(yabai), const_cast<char *>("-m"),
                        const_cast<char *>("query"),
                        const_cast<char *>("--displays"), nullptr};
  if (run(argv, &raw) != 0 || raw.empty()) return false;
  out = json::parse(raw, nullptr, /*allow_exceptions=*/false);
  return !out.is_discarded() && out.is_array();
}

// Build the "<label> <global>" map for every existing space.
static std::vector<std::pair<int, int>> build_map(const json &displays) {
  std::vector<std::pair<int, int>> result;

  auto spaces_for = [&](const std::string &uuid) -> const json * {
    for (const auto &d : displays) {
      if (d.value("uuid", "") == uuid) return &d;
    }
    return nullptr;
  };
  auto is_listed = [&](const std::string &uuid) {
    if (uuid == kAnchorUuid) return true;
    for (const auto *u : kFrontOrder)
      if (uuid == u) return true;
    return false;
  };

  // Front zone: ascending from 1, across the listed front displays then any
  // others not named here (ordered by yabai index), excluding the anchor.
  int label = 1;
  auto emit_front = [&](const json &disp) {
    for (const auto &s : disp.value("spaces", json::array()))
      result.emplace_back(label++, s.get<int>());
  };
  for (const auto *u : kFrontOrder) {
    if (const json *d = spaces_for(u)) emit_front(*d);
  }
  std::vector<const json *> others;
  for (const auto &d : displays) {
    if (!is_listed(d.value("uuid", ""))) others.push_back(&d);
  }
  std::sort(others.begin(), others.end(), [](const json *a, const json *b) {
    return a->value("index", 0) < b->value("index", 0);
  });
  for (const json *d : others) emit_front(*d);

  // Anchor zone: descending from kAnchorStart over the external's spaces
  // (oldest -> newest, so the oldest space is kAnchorStart).
  if (const json *d = spaces_for(kAnchorUuid)) {
    int i = 0;
    for (const auto &s : d->value("spaces", json::array()))
      result.emplace_back(kAnchorStart - i++, s.get<int>());
  }

  return result;
}

int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr, "Usage: %s --{focus|move} <label> | --map\n", argv[0]);
    return 1;
  }
  std::string action = argv[1];
  if (action != "--map" && action != "--focus" && action != "--move") {
    fprintf(stderr, "Usage: %s --{focus|move} <label> | --map\n", argv[0]);
    return 1;
  }

  json displays;
  if (!query_displays(displays)) return 0; // daemon down / bad output: no-op
  auto entries = build_map(displays);

  if (action == "--map") {
    for (const auto &[label, global] : entries) printf("%d %d\n", label, global);
    return 0;
  }

  // --focus / --move need a label argument.
  if (argc < 3) {
    fprintf(stderr, "Usage: %s --{focus|move} <label>\n", argv[0]);
    return 1;
  }
  int want = atoi(argv[2]);
  int target = -1;
  for (const auto &[label, global] : entries) {
    if (label == want) { target = global; break; }
  }
  if (target < 0) return 0; // no such label: no-op

  std::string num = std::to_string(target);
  const char *yabai = yabai_bin();
  if (action == "--move") {
    char *const mv[] = {const_cast<char *>(yabai), const_cast<char *>("-m"),
                        const_cast<char *>("window"), const_cast<char *>("--space"),
                        const_cast<char *>(num.c_str()), nullptr};
    if (run(mv, nullptr) != 0) return 0; // move failed: don't steal focus
  }
  char *const fc[] = {const_cast<char *>(yabai), const_cast<char *>("-m"),
                      const_cast<char *>("space"), const_cast<char *>("--focus"),
                      const_cast<char *>(num.c_str()), nullptr};
  run(fc, nullptr);
  return 0;
}
