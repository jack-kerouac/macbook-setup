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
  (.transcript_path // ""),
  (.cost.total_cost_usd // "" | tostring),
  (.worktree.branch // ""),
  (.worktree.original_cwd // "")
')
model="${_f[0]}"
effort="${_f[1]}"
total_tokens="${_f[2]}"
used_pct="${_f[3]}"
five_pct="${_f[4]}"
five_resets="${_f[5]}"
cwd="${_f[6]}"
transcript="${_f[7]}"
cost_usd="${_f[8]}"
wt_branch="${_f[9]}"
wt_original_cwd="${_f[10]}"

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

# 5. Prompt cache eviction countdown (TTL from last assistant message)
# Cache the last-seen assistant timestamp in a tmpfile to avoid re-scanning on every refresh
if [ -n "${ENABLE_PROMPT_CACHING_1H}" ]; then
  cache_ttl=3600; cache_label="cache (60m)"
else
  cache_ttl=300;  cache_label="cache (5m)"
fi
cache_str=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  _cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/claude/statusline"
  mkdir -p "$_cache_dir"
  cache_file="${_cache_dir}/$(echo "$transcript" | md5).ts"
  # Only re-scan if transcript has grown since last check
  transcript_size=$(stat -f%z "$transcript" 2>/dev/null)
  cached_meta=$(cat "$cache_file" 2>/dev/null)
  cached_size="${cached_meta%%:*}"
  cached_epoch="${cached_meta##*:}"
  if [ "$transcript_size" != "$cached_size" ]; then
    last_ts=$(tail -n 100 "$transcript" | grep '"type":"assistant"' | tail -n 1 | sed 's/.*"timestamp":"\([^"]*\)".*/\1/')
    if [ -n "$last_ts" ]; then
      ts_clean="${last_ts%%.*}"
      ts_clean="${ts_clean%Z}"
      ts_epoch=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$ts_clean" +%s 2>/dev/null)
      if [ -n "$ts_epoch" ]; then
        # Only advance the epoch on a genuinely newer assistant message.
        # If the file grew for other reasons (streaming, tool output), keep the
        # old epoch so the countdown continues instead of resetting to 60m.
        if [ "$ts_epoch" -gt "${cached_epoch:-0}" ]; then
          cached_epoch="$ts_epoch"
        fi
        echo "${transcript_size}:${cached_epoch}" > "$cache_file"
      fi
    fi
  fi
  if [ -n "$cached_epoch" ]; then
    now=$(date +%s)
    evict_at=$((cached_epoch + cache_ttl))
    remaining=$((evict_at - now))
    if [ "$remaining" -gt 0 ]; then
      mins=$((remaining / 60))
      secs=$((remaining % 60))
      cache_str="${cache_label}: ${mins}m ${secs}s"
    else
      cache_str="${cache_label}: \033[31;1mexpired\033[0m"
    fi
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
