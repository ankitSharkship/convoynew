/// Matches the backend's MAX_VIDEO_DURATION_SECONDS (config.py) — videos
/// longer than this are rejected server-side once Bunny reports their real
/// length, so the record/trim screens enforce the same cap up front rather
/// than letting a user record something that gets silently rejected later.
const reelMaxDurationSeconds = 30;
