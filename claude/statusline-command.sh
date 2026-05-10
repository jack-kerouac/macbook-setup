#!/usr/bin/env bash
# Claude Code status line command
# Reads JSON from stdin and outputs a formatted status line

input=$(cat)

# Extract all fields in one jq pass
mapfile -t _f < <(echo "$input" | jq -r '
  (.model.display_name // "unknown"),
  (.effort.level // ""),
  (.context_window.total_input_tokens // 0 | tostring),
  (.context_window.used_percentage // ""),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.five_hour.resets_at // "" | tostring),
  (.workspace.current_dir // .cwd // ""),
  (.transcript_path // "")
')
model="${_f[0]}"
effort="${_f[1]}"
total_tokens="${_f[2]}"
used_pct="${_f[3]}"
five_pct="${_f[4]}"
five_resets="${_f[5]}"
cwd="${_f[6]}"
transcript="${_f[7]}"

# 1. Model and effort level
if [ -n "$effort" ]; then
  model_str="$model [$effort]"
else
  model_str="$model"
fi

# 2. Context tokens and percentage
tokens_fmt=$(printf "%'d" "$total_tokens" 2>/dev/null || echo "$total_tokens")
if [ -n "$used_pct" ]; then
  ctx_str="ctx: ${tokens_fmt} tok ($(printf '%.0f' "$used_pct")%)"
else
  ctx_str="ctx: ${tokens_fmt} tok"
fi

# 3. Current working directory (below ~/src/) and git branch
src_prefix="$HOME/src/"
if [[ "$cwd" == "$src_prefix"* ]]; then
  rel_cwd="${cwd#$src_prefix}"
else
  rel_cwd="$cwd"
fi
branch=$(git --no-optional-locks -C "$cwd" branch --show-current 2>/dev/null)
if [ -n "$branch" ]; then
  dir_str="${rel_cwd} (${branch})"
else
  dir_str="${rel_cwd}"
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
else
  rate_str=""
fi

# 5. Prompt cache eviction countdown (60 min from last assistant message)
# Cache the last-seen assistant timestamp in a tmpfile to avoid re-scanning on every refresh
cache_str=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  cache_file="/tmp/ccstatusline_$(echo "$transcript" | md5).ts"
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
        echo "${transcript_size}:${ts_epoch}" > "$cache_file"
        cached_epoch="$ts_epoch"
      fi
    fi
  fi
  if [ -n "$cached_epoch" ]; then
    now=$(date +%s)
    evict_at=$((cached_epoch + 3600))
    remaining=$((evict_at - now))
    if [ "$remaining" -gt 0 ]; then
      mins=$((remaining / 60))
      cache_str="cache: ${mins}m"
    else
      cache_str="cache: \033[31;1mexpired\033[0m"
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

# Assemble: model | ctx | cwd/branch | 5h session | cache
colored_parts=()
colored_parts+=("${C_MODEL}${model_str}${C_RESET}")
colored_parts+=("${C_CTX}${ctx_str}${C_RESET}")
colored_parts+=("${C_DIR}${dir_str}${C_RESET}")
[ -n "$rate_str" ] && colored_parts+=("${C_RATE}${rate_str}${C_RESET}")
[ -n "$cache_str" ] && colored_parts+=("${C_CACHE}${cache_str}${C_RESET}")

# Join with separator
printf '%b' "${colored_parts[0]}"
for part in "${colored_parts[@]:1}"; do
  printf '%b' "${C_SEP} | ${C_RESET}${part}"
done
printf '\n'
