-- File change monitoring and notifications
return {
  name = "file-watcher",
  dir = vim.fn.stdpath("config"),
  config = function()
    -- More aggressive file watching
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
      pattern = "*",
      callback = function()
        if vim.fn.mode() ~= "c" then
          vim.cmd("checktime")
        end
      end,
    })

    -- Force check every second using CursorHold trigger
    vim.opt.updatetime = 1000

    -- Additional timer for background checking
    local function check_file_changes()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) ~= "" then
          vim.api.nvim_buf_call(buf, function()
            if vim.fn.mode() ~= "c" then
              vim.cmd("silent! checktime")
            end
          end)
        end
      end
    end

    local timer = vim.loop.new_timer()
    if timer then
      timer:start(2000, 2000, vim.schedule_wrap(check_file_changes))
    end

    -- Notify when file changed on disk for modified buffers
    vim.api.nvim_create_autocmd("FileChangedShellPost", {
      pattern = "*",
      callback = function()
        vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
      end,
    })

    -- Warn when file changed on disk for modified buffers
    vim.api.nvim_create_autocmd("FileChangedShell", {
      pattern = "*",
      callback = function()
        if vim.bo.modified then
          vim.notify("Warning: File has been changed on disk and buffer is modified!", vim.log.levels.WARN)
        end
      end,
    })
  end,
}