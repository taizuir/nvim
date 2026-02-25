-- ~/.config/nvim/ftplugin/java.lua
-- Charg automatiquement  chaque ouverture d'un fichier .java
-- Gre : LSP (jdtls) + DAP (java-debug-adapter + java-test)

local jdtls = require("jdtls")
local mason  = require("mason-registry")

-- ---------------------------------------------
-- Chemins Mason
-- ---------------------------------------------
local jdtls_path = mason.get_package("jdtls"):get_install_path()
local java_debug = mason.get_package("java-debug-adapter"):get_install_path()
local java_test  = mason.get_package("java-test"):get_install_path()

-- Workspace unique par projet (vite les conflits entre projets)
local project_name  = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspaces/" .. project_name

-- ---------------------------------------------
-- Bundles DAP
-- :MasonInstall java-debug-adapter java-test
-- ---------------------------------------------
local bundles = vim.list_extend(
	vim.fn.glob(java_debug .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", 1, 1),
	vim.fn.glob(java_test  .. "/extension/server/*.jar", 1, 1)
)

-- ---------------------------------------------
-- Configuration jdtls
-- ---------------------------------------------

-- Dtection OS pour le dossier config
local os_config = "config_linux"
if vim.fn.has("mac") == 1 then
	os_config = "config_mac"
elseif vim.fn.has("win32") == 1 then
	os_config = "config_win"
end

local config = {
	cmd = {
		"java",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xmx1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens", "java.base/java.util=ALL-UNNAMED",
		"--add-opens", "java.base/java.lang=ALL-UNNAMED",
		"-jar", vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
		"-configuration", jdtls_path .. "/" .. os_config,
		"-data", workspace_dir,
	},

	root_dir = require("jdtls.setup").find_root({
		".git", "mvnw", "gradlew", "pom.xml", "build.gradle",
	}),

	-- Capabilities hrites de blink.cmp (cohrent avec lsp.lua)
	capabilities = require("blink.cmp").get_lsp_capabilities(),

	settings = {
		java = {
			eclipse    = { downloadSources = true },
			maven      = { downloadSources = true },
			references = { includeDecompiledSources = true },
			inlayHints = { parameterNames = { enabled = "all" } },
			format     = { enabled = true },
			completion = {
				favoriteStaticMembers = {
					"org.junit.Assert.*",
					"org.junit.Assume.*",
					"org.junit.jupiter.api.Assertions.*",
				},
			},
		},
	},

	init_options = {
		bundles = bundles,
	},
}

-- ---------------------------------------------
-- Dmarrage + DAP setup au LspAttach
-- ---------------------------------------------
jdtls.start_or_attach(config)

vim.api.nvim_create_autocmd("LspAttach", {
	buffer   = 0,
	once     = true,
	callback = function()
		jdtls.setup_dap({ hotcodereplace = "auto" })
		jdtls.setup_dap_main_class_configs()
	end,
})

-- ---------------------------------------------
-- Keymaps Java
-- <leader>j*  ->  Java spcifique
-- <leader>d*  ->  DAP (dfini globalement dans debug.lua)
-- gr* / K     ->  LSP (dfini globalement dans lsp.lua)
-- ---------------------------------------------
local map = function(keys, func, desc)
	vim.keymap.set("n", keys, func, { buffer = 0, desc = "Java: " .. desc })
end

map("<leader>jo", jdtls.organize_imports,      "Organize imports")
map("<leader>jv", jdtls.extract_variable,      "Extract variable")
map("<leader>jc", jdtls.extract_constant,      "Extract constant")
map("<leader>jt", jdtls.test_class,            "Test class")
map("<leader>jT", jdtls.test_nearest_method,   "Test nearest method")
map("<leader>jU", jdtls.update_project_config, "Update project config")
