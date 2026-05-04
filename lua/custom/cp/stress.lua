-- Stress testing workflow.

local config = require('custom.cp.config')
local utils = require('custom.cp.utils')
local compiler = require('custom.cp.compiler')

local M = {}

--- Run a stress test: compile solution, generator, and brute, then iterate.
--- Usage: :CPStress [generator.c/cpp] [brute.c/cpp] [iterations]
---@param opts? table  { fargs = { ... } }
function M.stress_test(opts)
  opts = opts or {}
  local args = opts.fargs or {}

  local ctx = utils.get_cpp_context()
  if not ctx then
    return
  end

  local default_extension = utils.is_c_source(ctx.source_file) and 'c' or 'cpp'
  local generator_src = args[1] and vim.fn.fnamemodify(args[1], ':p') or (ctx.source_dir .. '/gen.' .. default_extension)
  local brute_src = args[2] and vim.fn.fnamemodify(args[2], ':p') or (ctx.source_dir .. '/brute.' .. default_extension)
  local iterations = tonumber(args[3]) or 200

  if iterations < 1 then
    vim.notify('Iterations must be >= 1.', vim.log.levels.ERROR)
    return
  end

  if vim.fn.filereadable(generator_src) == 0 then
    vim.notify('Generator source not found: ' .. generator_src, vim.log.levels.ERROR)
    return
  end

  if vim.fn.filereadable(brute_src) == 0 then
    vim.notify('Brute source not found: ' .. brute_src, vim.log.levels.ERROR)
    return
  end

  -- Stress testing must avoid LOCAL freopen redirection to compare stdin/stdout correctly.
  local solution_profile = compiler.get_compile_profile_for_source(ctx.source_file)
  local solution_flags = utils.strip_local_define(solution_profile.flags)
  local generator_profile = compiler.get_stress_compile_profile_for_source(generator_src)
  local brute_profile = compiler.get_stress_compile_profile_for_source(brute_src)
  local solution_bin = ctx.source_dir .. '/.stress_solution'
  local generator_bin = ctx.source_dir .. '/.stress_generator'
  local brute_bin = ctx.source_dir .. '/.stress_brute'

  vim.notify('Compiling stress-test binaries...', vim.log.levels.INFO)

  if not compiler.compile_source_file(ctx.source_file, solution_bin, solution_profile.compiler, solution_flags, 'Stress Test: solution compile errors') then
    vim.notify('Stress test aborted: solution compilation failed.', vim.log.levels.ERROR)
    return
  end

  if not compiler.compile_source_file(generator_src, generator_bin, generator_profile.compiler, generator_profile.flags, 'Stress Test: generator compile errors') then
    vim.notify('Stress test aborted: generator compilation failed.', vim.log.levels.ERROR)
    return
  end

  if not compiler.compile_source_file(brute_src, brute_bin, brute_profile.compiler, brute_profile.flags, 'Stress Test: brute compile errors') then
    vim.notify('Stress test aborted: brute compilation failed.', vim.log.levels.ERROR)
    return
  end

  local stress_input = ctx.source_dir .. '/.stress_input.txt'
  local stress_output = ctx.source_dir .. '/.stress_output.txt'
  local stress_expected = ctx.source_dir .. '/.stress_expected.txt'
  local stress_diff = ctx.source_dir .. '/.stress_diff.txt'

  local script = string.format(
    [[
i=1
max=%d
while [ "$i" -le "$max" ]; do
  %s > %s || exit 2
  %s < %s > %s || exit 3
  %s < %s > %s || exit 4
  if ! diff -u %s %s > %s; then
    echo "Mismatch on test #$i"
    echo "Input:"
    cat %s
    echo
    echo "Diff:"
    cat %s
    exit 1
  fi
  echo "Passed test #$i"
  i=$((i + 1))
done
echo "All stress tests passed: %d"
]],
    iterations,
    vim.fn.shellescape(generator_bin),
    vim.fn.shellescape(stress_input),
    vim.fn.shellescape(solution_bin),
    vim.fn.shellescape(stress_input),
    vim.fn.shellescape(stress_output),
    vim.fn.shellescape(brute_bin),
    vim.fn.shellescape(stress_input),
    vim.fn.shellescape(stress_expected),
    vim.fn.shellescape(stress_expected),
    vim.fn.shellescape(stress_output),
    vim.fn.shellescape(stress_diff),
    vim.fn.shellescape(stress_input),
    vim.fn.shellescape(stress_diff),
    iterations
  )

  utils.open_terminal_script(script)
  vim.notify('Stress test started (' .. iterations .. ' iterations).', vim.log.levels.INFO)
end

return M
