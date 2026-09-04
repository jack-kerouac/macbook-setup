#!/usr/bin/env bash
# Claude Code status line command
# Reads JSON from stdin and outputs a formatted status line

input=$(cat)

# Extract all fields in one jq pass (bash 3.2-compatible — no mapfile)
_f=()
while IFS= read -r line; do _f+=("$line"); done < <(echo "$input" | jq -r '
  (.model.display_name // "unknown"),
  (.effort.level // ""),
  (.context_window.total_input_tokens // 0 | tostring),
  (.context_window.used_percentage // ""),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.five_hour.resets_at // "" | tostring),
  (.workspace.current_dir // .cwd // ""),
  (.cost.total_cost_usd // "" | tostring),
  (.worktree.branch // ""),
  (.worktree.original_cwd // ""),
  (.prompt_cache.ttl // ""),
  (.prompt_cache.expires_at // "" | tostring),
  (.prompt_cache.warm | tostring)
')
model="${_f[0]}"
effort="${_f[1]}"
total_tokens="${_f[2]}"
used_pct="${_f[3]}"
five_pct="${_f[4]}"
five_resets="${_f[5]}"
cwd="${_f[6]}"
cost_usd="${_f[7]}"
wt_branch="${_f[8]}"
wt_original_cwd="${_f[9]}"
cache_ttl="${_f[10]}"
cache_expires="${_f[11]}"
cache_warm="${_f[12]}"

# 1. Model and effort level
if [ -n "$effort" ]; then
  model_str="$model [$effort]"
else
  model_str="$model"
fi

# 2. Context tokens and percentage
tokens_fmt=$(awk "BEGIN { printf \"%.1fk\", $total_tokens / 1000 }")
if [ -n "$used_pct" ]; then
  ctx_str="ctx: ${tokens_fmt} ($(printf '%.0f' "$used_pct")%)"
else
  ctx_str="ctx: ${tokens_fmt}"
fi

# 3. Current working directory (relative to home) and git branch
rel_path() { local p="$1"; [[ "$p" == "$HOME"* ]] && printf '~%s' "${p#$HOME}" || printf '%s' "$p"; }
if [ -n "$wt_original_cwd" ]; then
  dir_str="$(rel_path "$wt_original_cwd") (worktree: ⎇ ${wt_branch})"
else
  branch=$(git --no-optional-locks -C "$cwd" branch --show-current 2>/dev/null)
  dir_str="$(rel_path "$cwd")${branch:+ (⎇ ${branch})}"
fi

# 4. 5h subscription session usage and reset time
if [ -n "$five_pct" ] && [ -n "$five_resets" ]; then
  now_ts=$(date +%s)
  secs_left=$(( five_resets - now_ts ))
  if [ "$secs_left" -gt 0 ]; then
    hrs_left=$(( secs_left / 3600 ))
    mins_left=$(( (secs_left % 3600) / 60 ))
    if [ "$hrs_left" -gt 0 ]; then
      remaining_str="${hrs_left}h ${mins_left}m remaining"
    else
      remaining_str="${mins_left}m remaining"
    fi
  else
    remaining_str="reset now"
  fi
  rate_str="5h session: $(printf '%.0f' "$five_pct")% ($remaining_str)"
elif [ -n "$five_pct" ]; then
  rate_str="5h session: $(printf '%.0f' "$five_pct")%"
elif [ -n "$cost_usd" ]; then
  rate_str="cost: $(printf '$%.2f' "$cost_usd")"
else
  rate_str=""
fi

# 5. Prompt cache eviction countdown (Claude Code reports TTL and expiry)
cache_str=""
if [ -n "$cache_ttl" ]; then
  cache_label="cache (${cache_ttl})"
  remaining=0
  [ -n "$cache_expires" ] && remaining=$(( cache_expires - $(date +%s) ))
  if [ "$cache_warm" = "true" ] && [ "$remaining" -gt 0 ]; then
    cache_str="${cache_label}: $((remaining / 60))m $((remaining % 60))s"
  else
    cache_str="${cache_label}: \033[31;1mexpired\033[0m"
  fi
fi

# ANSI color codes (light, subtle)
C_RESET='\033[0m'
C_MODEL='\033[38;5;110m'    # light steel blue   — model/effort
C_CTX='\033[38;5;150m'      # light sage green    — context tokens
C_RATE='\033[38;5;216m'     # light peach/orange  — 5h session usage
C_DIR='\033[38;5;183m'      # light lavender      — working dir/branch
C_CACHE='\033[38;5;152m'    # light cyan-grey     — cache eviction
C_SEP='\033[38;5;240m'      # dim grey            — separator

# Assemble: model | cwd/branch | ctx | cache | cost
colored_parts=()
colored_parts+=("${C_MODEL}${model_str}${C_RESET}")
colored_parts+=("${C_DIR}${dir_str}${C_RESET}")
colored_parts+=("${C_CTX}${ctx_str}${C_RESET}")
[ -n "$cache_str" ] && colored_parts+=("${C_CACHE}${cache_str}${C_RESET}")
[ -n "$rate_str" ] && colored_parts+=("${C_RATE}${rate_str}${C_RESET}")

# Join with separator
printf '%b' "${colored_parts[0]}"
for part in "${colored_parts[@]:1}"; do
  printf '%b' "${C_SEP} | ${C_RESET}${part}"
done
printf '\n'
