export const NotificationPlugin = async ({ project, client, $, directory, worktree }) => {
  return {
    event: async ({ event }) => {
      // Send notification on session completion
      if (event.type === "session.idle") {
        await $`/usr/local/bin/dev-notify.sh "opencode - Session Complete" "Session done." "normal"`
      }
    },
  }
}
