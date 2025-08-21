-- Text alignment plugin
return {
  "junegunn/vim-easy-align",
  config = function()
    -- Start interactive EasyAlign in visual mode (e.g. vipga)
    vim.keymap.set('x', 'ga', '<Plug>(EasyAlign)', { desc = "Easy Align" })
    
    -- Start interactive EasyAlign for a motion/text object (e.g. gaip)
    vim.keymap.set('n', 'ga', '<Plug>(EasyAlign)', { desc = "Easy Align" })
    
    -- Custom alignment rules
    vim.g.easy_align_delimiters = {
      ['--'] = {
        pattern = '--',
        left_margin = 2,
        right_margin = 1,
        stick_to_left = 0
      }
    }
  end,
}