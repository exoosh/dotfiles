-- Test harness for ansible treesitter highlighting.
-- Run with: make test

vim.defer_fn(function()
  local parser = vim.treesitter.get_parser(0)
  parser:parse(true)

  io.write('parser: ' .. parser:lang() .. '\n')
  for lang, _ in pairs(parser:children()) do
    io.write('injected: ' .. lang .. '\n')
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local function find_line(pattern)
    for i, line in ipairs(lines) do
      if line:find(pattern, 1, true) then return i - 1 end
    end
    return nil
  end

  local function find_col(line_idx, text)
    local line = lines[line_idx + 1]
    local s = line:find(text, 1, true)
    return s and s - 1 or nil
  end

  local function has_capture(line_idx, col, expected)
    local captures = vim.treesitter.get_captures_at_pos(0, line_idx, col)
    for _, cap in ipairs(captures) do
      if cap.capture == expected then return true end
    end
    return false
  end

  local function test(desc, line_text, key_text, expected_capture)
    local line_idx = find_line(line_text)
    if not line_idx then
      return 'skip', desc .. ' (line not found)'
    end
    local col = find_col(line_idx, key_text)
    if not col then
      return 'skip', desc .. ' (key not found on line ' .. line_idx .. ')'
    end
    if has_capture(line_idx, col, expected_capture) then
      return 'pass', desc
    end
    local captures = vim.treesitter.get_captures_at_pos(0, line_idx, col)
    local caps = {}
    for _, cap in ipairs(captures) do
      caps[#caps + 1] = '@' .. cap.capture .. '(' .. cap.lang .. ')'
    end
    return 'fail', desc .. ' [' .. line_idx .. ':' .. col .. '] expected @' .. expected_capture .. ' got: ' .. table.concat(caps, ', ')
  end

  local results = { pass = 0, fail = 0, skip = 0 }
  local failures = {}

  local function run(desc, line_text, key_text, expected)
    local status, msg = test(desc, line_text, key_text, expected)
    results[status] = results[status] + 1
    if status == 'fail' then
      failures[#failures + 1] = msg
    elseif status == 'skip' then
      io.write('  SKIP: ' .. msg .. '\n')
    end
  end

  io.write('\n--- @keyword.ansible.control ---\n')
  run('name',           '- name: Configure',      'name',           'keyword.ansible.control')
  run('hosts',          'hosts: webservers',       'hosts',          'keyword.ansible.control')
  run('pre_tasks',      'pre_tasks:',              'pre_tasks',      'keyword.ansible.control')
  run('roles',          'roles:',                  'roles',          'keyword.ansible.control')
  run('tasks',          'tasks:',                  'tasks',          'keyword.ansible.control')
  run('register',       'register: install_result','register',       'keyword.ansible.control')
  run('notify',         'notify: restart nginx',   'notify',         'keyword.ansible.control')
  run('when',           'when: ansible_os_family', 'when',           'keyword.ansible.control')
  run('block',          'block:',                  'block',          'keyword.ansible.control')
  run('rescue',         'rescue:',                 'rescue',         'keyword.ansible.control')
  run('always',         'always:',                 'always',         'keyword.ansible.control')
  run('collections',    'collections:',            'collections',    'keyword.ansible.control')
  run('include_tasks',  'include_tasks:',          'include_tasks',  'keyword.ansible.control')
  run('import_tasks',   'import_tasks:',           'import_tasks',   'keyword.ansible.control')
  run('include_role',   'include_role:',           'include_role',   'keyword.ansible.control')
  run('import_role',    'import_role:',            'import_role',    'keyword.ansible.control')
  run('post_tasks',     'post_tasks:',             'post_tasks',     'keyword.ansible.control')
  run('handlers',       'handlers:',               'handlers',       'keyword.ansible.control')
  run('listen',         'listen:',                 'listen',         'keyword.ansible.control')
  run('changed_when',   'changed_when:',           'changed_when',   'keyword.ansible.control')
  run('failed_when',    'failed_when:',            'failed_when',    'keyword.ansible.control')

  io.write('\n--- @keyword.ansible.loop ---\n')
  run('loop',           'loop:',                   'loop',           'keyword.ansible.loop')
  run('loop_control',   'loop_control:',           'loop_control',   'keyword.ansible.loop')
  run('until',          'until:',                  'until',          'keyword.ansible.loop')
  run('retries',        'retries:',                'retries',        'keyword.ansible.loop')
  run('delay',          'delay:',                  'delay',          'keyword.ansible.loop')
  run('with_items',     'with_items:',             'with_items',     'keyword.ansible.loop')
  run('with_dict',      'with_dict:',              'with_dict',      'keyword.ansible.loop')

  io.write('\n--- @keyword.ansible.directive ---\n')
  run('become',             'become: true',             'become',             'keyword.ansible.directive')
  run('become_user',        'become_user:',             'become_user',        'keyword.ansible.directive')
  run('become_method',      'become_method:',           'become_method',      'keyword.ansible.directive')
  run('gather_facts',       'gather_facts:',            'gather_facts',       'keyword.ansible.directive')
  run('connection',         'connection:',              'connection',         'keyword.ansible.directive')
  run('serial',             'serial:',                  'serial',             'keyword.ansible.directive')
  run('strategy',           'strategy:',                'strategy',           'keyword.ansible.directive')
  run('environment',        'environment:',             'environment',        'keyword.ansible.directive')
  run('vars',               'vars:',                    'vars',               'keyword.ansible.directive')
  run('vars_files',         'vars_files:',              'vars_files',         'keyword.ansible.directive')
  run('tags',               'tags:',                    'tags',               'keyword.ansible.directive')
  run('ignore_errors',      'ignore_errors:',           'ignore_errors',      'keyword.ansible.directive')
  run('check_mode',         'check_mode:',              'check_mode',         'keyword.ansible.directive')
  run('no_log',             'no_log:',                  'no_log',             'keyword.ansible.directive')
  run('async',              'async:',                   'async',              'keyword.ansible.directive')
  run('poll',               'poll:',                    'poll',               'keyword.ansible.directive')
  run('delegate_to',        'delegate_to:',             'delegate_to',        'keyword.ansible.directive')
  run('delegate_facts',     'delegate_facts:',          'delegate_facts',     'keyword.ansible.directive')
  run('run_once',           'run_once:',                'run_once',           'keyword.ansible.directive')
  run('throttle',           'throttle:',                'throttle',           'keyword.ansible.directive')
  run('timeout',            'timeout:',                 'timeout',            'keyword.ansible.directive')
  run('diff',               'diff:',                    'diff',               'keyword.ansible.directive')
  run('any_errors_fatal',   'any_errors_fatal:',        'any_errors_fatal',   'keyword.ansible.directive')
  run('ignore_unreachable', 'ignore_unreachable:',      'ignore_unreachable', 'keyword.ansible.directive')
  run('max_fail_percentage','max_fail_percentage:',     'max_fail_percentage','keyword.ansible.directive')
  run('module_defaults',    'module_defaults:',         'module_defaults',    'keyword.ansible.directive')

  io.write('\n--- @keyword.ansible.debug ---\n')
  run('debug', 'debug:', 'debug', 'keyword.ansible.debug')

  io.write('\n--- Jinja2 (ansible parser layer) ---\n')
  run('{{ delimiter',   'Install {{ pkg_name }}',          '{{',  'keyword.directive')
  run('{# comment',     '{# This is a Jinja2 comment',     '{#',  'comment')
  run('{% block',       '{% if extra_tasks',               '{%',  'keyword.directive')

  io.write('\n')
  for _, msg in ipairs(failures) do
    io.write('FAIL: ' .. msg .. '\n')
  end
  io.write('\n' .. results.pass .. ' passed, ' .. results.fail .. ' failed, ' .. results.skip .. ' skipped\n')
  io.stdout:flush()
  vim.cmd('qa!')
end, 2000)
