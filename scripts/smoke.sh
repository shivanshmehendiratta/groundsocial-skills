#!/usr/bin/env bash
# Needs curl and jq. Runs one cheap call from each skill against the live API (about 40 credits). Needs GROUNDSOCIAL_API_KEY.
set -u
gs() { curl -sS -G "https://api.groundsocial.dev$1" -H "Authorization: Bearer $GROUNDSOCIAL_API_KEY" "${@:2}"; }
fail=0
check() {
  local name=$1; shift
  # Fails on a top-level {"error": ...}; composite responses may carry per-leg errors, which are fine.
  if "$@" | jq -e 'type == "object" and has("error")' >/dev/null; then echo "FAIL $name"; fail=1; else echo "ok   $name"; fi
}
check groundsocial-api            gs /v1/utility/find --data-urlencode "task=reddit posts about a product"
check brand-mention-scan          gs /v1/prism/mentions --data-urlencode "name=Supabase" -d platforms=reddit,hackernews,bluesky
check competitor-social-audit     gs /v1/prism/creator-card -d handle=supabase
check creator-vetting             gs /v1/prism/creator-vet -d handle=mkbhd -d platform=tiktok
check subreddit-research          gs /v1/reddit/subreddits/selfhosted/rules
check tiktok-trend-scan           gs /v1/tiktok/trending/hashtags -d country=US -d period=7
check youtube-transcript-research gs /v1/youtube/videos/dQw4w9WgXcQ/transcript -d language=en
check comment-mining              gs /v1/youtube/videos/dQw4w9WgXcQ/comments -d order=top
exit $fail
