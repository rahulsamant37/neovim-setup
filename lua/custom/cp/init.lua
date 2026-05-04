-- CP module public API.
-- Re-exports key functions from submodules for external use.

local config = require('custom.cp.config')
local runner = require('custom.cp.runner')
local testcase = require('custom.cp.testcase')
local stress = require('custom.cp.stress')

return {
  compile_and_run = runner.compile_and_run,
  compile_only = runner.compile_only,
  create_test_files = testcase.create_test_files,
  compare_output = testcase.compare_output,
  clear_test_residue = testcase.clear_test_residue,
  new_cp_file = runner.new_cp_file,
  stress_test = stress.stress_test,
  set_compile_mode = config.set_compile_mode,
  cycle_compile_mode = config.cycle_compile_mode,
}
