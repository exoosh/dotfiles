local M = {}
local did_setup = false

--- Read and concatenate all query files for a given language and query name.
---@param lang string
---@param query_name string
---@return string
local function read_query(lang, query_name)
  local files = vim.treesitter.query.get_files(lang, query_name)
  local texts = {}
  for _, f in ipairs(files) do
    local fh = io.open(f, 'r')
    if fh then
      table.insert(texts, fh:read('*a'))
      fh:close()
    end
  end
  return table.concat(texts, '\n')
end

-- stylua: ignore
local yaml_ansible_highlights = [[
; Ansible: task structure and control flow
(block_mapping_pair
  key: (flow_node
    (plain_scalar
      (string_scalar) @keyword.ansible.control
      (#any-of? @keyword.ansible.control
        "name" "hosts"
        "tasks" "handlers" "pre_tasks" "post_tasks"
        "block" "rescue" "always"
        "when" "changed_when" "failed_when"
        "notify" "listen"
        "register"
        "action" "local_action"
        "include" "include_role" "include_tasks" "include_vars"
        "import_role" "import_playbook" "import_tasks"
        "roles" "collections")))
  (#set! priority 105))

; Ansible: loop keywords
(block_mapping_pair
  key: (flow_node
    (plain_scalar
      (string_scalar) @keyword.ansible.loop
      (#any-of? @keyword.ansible.loop
        "loop" "loop_control" "until" "retries" "delay")))
  (#set! priority 105))

; Ansible: with_* loop keywords (with_items, with_dict, with_fileglob, etc.)
(block_mapping_pair
  key: (flow_node
    (plain_scalar
      (string_scalar) @keyword.ansible.loop
      (#lua-match? @keyword.ansible.loop "^with_")))
  (#set! priority 105))

; Ansible: privilege escalation, execution control, and directives
(block_mapping_pair
  key: (flow_node
    (plain_scalar
      (string_scalar) @keyword.ansible.directive
      (#any-of? @keyword.ansible.directive
        "become" "become_exe" "become_flags" "become_method" "become_user" "become_pass"
        "check_mode" "diff" "no_log"
        "any_errors_fatal" "ignore_errors" "ignore_unreachable" "max_fail_percentage"
        "environment" "vars" "vars_files" "vars_prompt"
        "connection" "port" "remote_user"
        "async" "poll" "throttle" "timeout"
        "order" "run_once" "serial" "strategy"
        "delegate_facts" "delegate_to"
        "tags" "args" "force_handlers"
        "debugger" "always_run" "prompt_l10n"
        "gather_facts" "gather_subset" "gather_timeout" "fact_path"
        "module_defaults")))
  (#set! priority 105))

; Ansible: debug module
(block_mapping_pair
  key: (flow_node
    (plain_scalar
      (string_scalar) @keyword.ansible.debug
      (#eq? @keyword.ansible.debug "debug")))
  (#set! priority 105))
]]

--- Enable tree-sitter highlighting for Ansible files.
---
--- Uses the jinja parser to tokenize Jinja2 template boundaries ({{ }}, {% %}, {# #}).
--- YAML is injected into the content between template expressions.
--- Ansible keyword highlighting is applied to the injected YAML layer.
---
--- Requires the `jinja` and `yaml` tree-sitter parsers to be installed.
---
--- Custom highlight groups (override in your config or colorscheme):
---   @keyword.ansible.control   — tasks, handlers, when, register, notify, etc.
---   @keyword.ansible.loop      — loop, with_items, until, retries, delay, etc.
---   @keyword.ansible.directive — become, vars, connection, ignore_errors, etc.
---   @keyword.ansible.debug     — debug
function M.setup()
  if did_setup then
    return
  end
  did_setup = true

  local jinja_paths = vim.api.nvim_get_runtime_file('parser/jinja.*', false)
  if not jinja_paths[1] then
    vim.notify(
      'ansible.setup(): jinja parser not found. Install with :TSInstall jinja',
      vim.log.levels.WARN
    )
    return
  end

  vim.treesitter.language.add('ansible', {
    path = jinja_paths[1],
    symbol_name = 'jinja',
  })

  -- Extend yaml highlights with Ansible keyword patterns
  local yaml_hl = read_query('yaml', 'highlights')
  vim.treesitter.query.set('yaml', 'highlights', yaml_hl .. '\n' .. yaml_ansible_highlights)

  vim.api.nvim_set_hl(0, '@keyword.ansible.control', { default = true, link = 'Conditional' })
  vim.api.nvim_set_hl(0, '@keyword.ansible.loop', { default = true, link = 'Special' })
  vim.api.nvim_set_hl(0, '@keyword.ansible.directive', { default = true, link = 'Identifier' })
  vim.api.nvim_set_hl(0, '@keyword.ansible.debug', { default = true, link = 'Debug' })

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'ansible',
    callback = function(args)
      if vim._ts_has_language('ansible') then
        vim.bo[args.buf].syntax = ''
        vim.treesitter.start(args.buf, 'ansible')
      end
    end,
  })

  -- Activate on any already-open ansible buffers
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == 'ansible' then
      vim.bo[buf].syntax = ''
      vim.treesitter.start(buf, 'ansible')
    end
  end
end

return M
