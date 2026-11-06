---
name: notify
description: Get the user's attention with a desktop notification and a flashing terminal window. Use whenever you are blocked on the user — you need an answer, approval, a decision, a permission, a secret/credential you can't read, or a long task has finished and the user is probably away from the terminal. Use it before you stop and wait on the user, even if they didn't ask for a notification.
---

# notify

The user often isn't watching the terminal. When you need them, run `blink -n` so they get a desktop notification and the terminal window is flagged as demanding attention.

`blink` is a shell function (from the user's dotfiles), so call it through an interactive-aware shell if plain `blink` isn't found: `bash -ic 'blink -n "<message>"'`.

## Message format

`<session name> | <what you need>`

- **Session name**: use the name the user gave this session (e.g. via `/rename`) if you know it; otherwise the current directory's basename (add the git branch if in a repo, e.g. `myrepo@feature-x`). The notification is the only context the user gets, and they may run several sessions at once, so it must say which one is calling.
- **What you need**: one short, specific sentence — "need approval to delete the build/ dir", "which DB should the migration target?", "task finished, tests pass". Not "need input".

Keep the message free of quotes, `$`, and backticks (it goes through the shell), and never include secrets.

## Example

```bash
bash -ic 'blink -n "myrepo@fix-auth | need your decision: keep legacy login endpoint or remove it?"'
```

Send the notification, then ask your question in the normal reply as well — the notification only gets attention, the conversation carries the details. Send one notification per wait, not repeated ones.
