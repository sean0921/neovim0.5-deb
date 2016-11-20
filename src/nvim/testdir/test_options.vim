" Test for options

func Test_filetype_valid()
  set ft=valid_name
  call assert_equal("valid_name", &filetype)
  set ft=valid-name
  call assert_equal("valid-name", &filetype)

  call assert_fails(":set ft=wrong;name", "E474:")
  call assert_fails(":set ft=wrong\\\\name", "E474:")
  call assert_fails(":set ft=wrong\\|name", "E474:")
  call assert_fails(":set ft=wrong/name", "E474:")
  call assert_fails(":set ft=wrong\\\nname", "E474:")
  call assert_equal("valid-name", &filetype)

  exe "set ft=trunc\x00name"
  call assert_equal("trunc", &filetype)
endfunc

func Test_syntax_valid()
  set syn=valid_name
  call assert_equal("valid_name", &syntax)
  set syn=valid-name
  call assert_equal("valid-name", &syntax)

  call assert_fails(":set syn=wrong;name", "E474:")
  call assert_fails(":set syn=wrong\\\\name", "E474:")
  call assert_fails(":set syn=wrong\\|name", "E474:")
  call assert_fails(":set syn=wrong/name", "E474:")
  call assert_fails(":set syn=wrong\\\nname", "E474:")
  call assert_equal("valid-name", &syntax)

  exe "set syn=trunc\x00name"
  call assert_equal("trunc", &syntax)
endfunc

func Test_keymap_valid()
  call assert_fails(":set kmp=valid_name", "E544:")
  call assert_fails(":set kmp=valid_name", "valid_name")
  call assert_fails(":set kmp=valid-name", "E544:")
  call assert_fails(":set kmp=valid-name", "valid-name")

  call assert_fails(":set kmp=wrong;name", "E474:")
  call assert_fails(":set kmp=wrong\\\\name", "E474:")
  call assert_fails(":set kmp=wrong\\|name", "E474:")
  call assert_fails(":set kmp=wrong/name", "E474:")
  call assert_fails(":set kmp=wrong\\\nname", "E474:")

  call assert_fails(":set kmp=trunc\x00name", "E544:")
  call assert_fails(":set kmp=trunc\x00name", "trunc")
endfunc
