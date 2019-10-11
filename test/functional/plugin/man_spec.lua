local helpers = require('test.functional.helpers')(after_each)
local Screen = require('test.functional.ui.screen')
local command, eval, rawfeed = helpers.command, helpers.eval, helpers.rawfeed
local clear = helpers.clear

describe(':Man', function()
  describe('man.lua: highlight_line()', function()
    local screen

    before_each(function()
      clear()
      command('syntax on')
      command('set filetype=man')
      command('syntax off')  -- Ignore syntax groups
      screen = Screen.new(52, 5)
      screen:set_default_attr_ids({
        b = { bold = true },
        i = { italic = true },
        u = { underline = true },
        bi = { bold = true, italic = true },
        biu = { bold = true, italic = true, underline = true },
      })
      screen:set_default_attr_ignore({
        { foreground = Screen.colors.Blue }, -- control chars
        { bold = true, foreground = Screen.colors.Blue } -- empty line '~'s
      })
      screen:attach()
    end)

    after_each(function()
      screen:detach()
    end)

    it('clears backspaces from text and adds highlights', function()
      rawfeed([[
        ithis i<C-v><C-h>is<C-v><C-h>s a<C-v><C-h>a test
        with _<C-v><C-h>o_<C-v><C-h>v_<C-v><C-h>e_<C-v><C-h>r_<C-v><C-h>s_<C-v><C-h>t_<C-v><C-h>r_<C-v><C-h>u_<C-v><C-h>c_<C-v><C-h>k text<ESC>]])

      screen:expect([[
      this i^His^Hs a^Ha test                             |
      with _^Ho_^Hv_^He_^Hr_^Hs_^Ht_^Hr_^Hu_^Hc_^Hk tex^t  |
      ~                                                   |
      ~                                                   |
                                                          |
      ]])

      eval('man#init_pager()')

      screen:expect([[
      ^this {b:is} {b:a} test                                      |
      with {u:overstruck} text                                |
      ~                                                   |
      ~                                                   |
                                                          |
      ]])
    end)

    it('clears escape sequences from text and adds highlights', function()
      rawfeed([[
        ithis <C-v><ESC>[1mis <C-v><ESC>[3ma <C-v><ESC>[4mtest<C-v><ESC>[0m
        <C-v><ESC>[4mwith<C-v><ESC>[24m <C-v><ESC>[4mescaped<C-v><ESC>[24m <C-v><ESC>[4mtext<C-v><ESC>[24m<ESC>]])

      screen:expect([=[
      this ^[[1mis ^[[3ma ^[[4mtest^[[0m                  |
      ^[[4mwith^[[24m ^[[4mescaped^[[24m ^[[4mtext^[[24^m  |
      ~                                                   |
      ~                                                   |
                                                          |
      ]=])

      eval('man#init_pager()')

      screen:expect([[
      ^this {b:is }{bi:a }{biu:test}                                      |
      {u:with} {u:escaped} {u:text}                                   |
      ~                                                   |
      ~                                                   |
                                                          |
      ]])
    end)

    it('highlights multibyte text', function()
      rawfeed([[
        ithis i<C-v><C-h>is<C-v><C-h>s あ<C-v><C-h>あ test
        with _<C-v><C-h>ö_<C-v><C-h>v_<C-v><C-h>e_<C-v><C-h>r_<C-v><C-h>s_<C-v><C-h>t_<C-v><C-h>r_<C-v><C-h>u_<C-v><C-h>̃_<C-v><C-h>c_<C-v><C-h>k te<C-v><ESC>[3mxt¶<C-v><ESC>[0m<ESC>]])
      eval('man#init_pager()')

      screen:expect([[
      ^this {b:is} {b:あ} test                                     |
      with {u:överstrũck} te{i:xt¶}                               |
      ~                                                   |
      ~                                                   |
                                                          |
      ]])
    end)

    it('highlights underscores based on context', function()
      rawfeed([[
        i_<C-v><C-h>_b<C-v><C-h>be<C-v><C-h>eg<C-v><C-h>gi<C-v><C-h>in<C-v><C-h>ns<C-v><C-h>s
        m<C-v><C-h>mi<C-v><C-h>id<C-v><C-h>d_<C-v><C-h>_d<C-v><C-h>dl<C-v><C-h>le<C-v><C-h>e
        _<C-v><C-h>m_<C-v><C-h>i_<C-v><C-h>d_<C-v><C-h>__<C-v><C-h>d_<C-v><C-h>l_<C-v><C-h>e<ESC>]])
      eval('man#init_pager()')

      screen:expect([[
      {b:^_begins}                                             |
      {b:mid_dle}                                             |
      {u:mid_dle}                                             |
      ~                                                   |
                                                          |
      ]])
    end)

    it('highlights various bullet formats', function()
      rawfeed([[
        i· ·<C-v><C-h>·
        +<C-v><C-h>o
        +<C-v><C-h>+<C-v><C-h>o<C-v><C-h>o double<ESC>]])
      eval('man#init_pager()')

      screen:expect([[
      ^· {b:·}                                                 |
      {b:·}                                                   |
      {b:·} double                                            |
      ~                                                   |
                                                          |
      ]])
    end)

    it('handles : characters in input', function()
      rawfeed([[
        i<C-v><C-[>[40m    0  <C-v><C-[>[41m    1  <C-v><C-[>[42m    2  <C-v><C-[>[43m    3
        <C-v><C-[>[44m    4  <C-v><C-[>[45m    5  <C-v><C-[>[46m    6  <C-v><C-[>[47m    7  <C-v><C-[>[100m    8  <C-v><C-[>[101m    9
        <C-v><C-[>[102m   10  <C-v><C-[>[103m   11  <C-v><C-[>[104m   12  <C-v><C-[>[105m   13  <C-v><C-[>[106m   14  <C-v><C-[>[107m   15
        <C-v><C-[>[48:5:16m   16  <ESC>]])
      eval('man#init_pager()')

      screen:expect([[
       ^    0      1      2      3                          |
           4      5      6      7      8      9            |
          10     11     12     13     14     15            |
          16                                               |
                                                           |
      ]])
    end)
  end)
end)
