// Import from `vocs/config`, not `vocs`: the root entry pulls in the React component barrel,
// which needs the `~icons` virtual module and is not resolvable while loading the config.
import { defineConfig } from 'vocs/config'

const tevmSites = [
	{ text: 'Tevm', link: 'https://tevm.sh' },
	{ text: 'Contract', link: 'https://contract.tevm.sh' },
	{ text: 'Logger', link: 'https://logger.tevm.sh' },
	{ text: 'Test', link: 'https://test.tevm.sh' },
	{ text: 'Bundler', link: 'https://bundler.tevm.sh' },
	{ text: 'CLI', link: 'https://cli.tevm.sh' },
	{ text: 'Ethers', link: 'https://ethers.tevm.sh' },
	{ text: 'MUD', link: 'https://mud.tevm.sh' },
	{ text: 'Examples', link: 'https://examples.tevm.sh' },
	{ text: 'Voltaire', link: 'https://voltaire.tevm.sh' },
	{ text: 'Guillotine', link: 'https://guillotine.tevm.sh' },
	{ text: 'Mini', link: 'https://mini.tevm.sh' },
	{ text: 'ZEVM', link: 'https://zevm.tevm.sh' },
] as const

export default defineConfig({
	title: 'Guillotine Mini',
	titleTemplate: '%s · Guillotine Mini',
	description:
		'A minimal, readable Ethereum Virtual Machine written in Zig — the reference implementation of the Guillotine family, validated against the ethereum/tests suite from Berlin through Prague.',
	baseUrl: 'https://mini.tevm.sh',
	accentColor: 'light-dark(#0588f0, #3b9eff)',
	colorScheme: 'light dark',
	iconUrl: '/favicon.svg',
	logoUrl: {
		light: '/logo-light.svg',
		dark: '/logo-dark.svg',
	},
	ogImageUrl: 'https://vocs.dev/api/og?logo=%logo&title=%title&description=%description',
	renderStrategy: 'full-static',
	checkDeadlinks: 'warn',
	editLink: {
		link: 'https://github.com/evmts/guillotine-mini/edit/main/docs/:path',
		text: 'Edit on GitHub',
	},
	topNav: [
		{ text: 'Home', link: '/' },
		{ text: 'Explorer', link: '/opcode-explorer', match: '/opcode-explorer' },
		{ text: 'Ecosystem', items: tevmSites.map((s) => ({ ...s })) },
		{ text: 'GitHub', link: 'https://github.com/evmts/guillotine-mini' },
	],
	socials: [
		{ icon: 'github', link: 'https://github.com/evmts/guillotine-mini' },
		{ icon: 'x', link: 'https://x.com/tevmtools' },
		{ icon: 'telegram', link: 'https://t.me/+ANThR9bHDLAwMjUx' },
	],
	sidebar: [
		{
			text: 'Guillotine Mini',
			collapsed: false,
			items: [
				{ text: 'Overview', link: '/' },
				{ text: 'Getting Started', link: '/getting-started' },
				{ text: 'Building from Source', link: '/native-build' },
				{ text: 'Opcode & gas explorer', link: '/opcode-explorer' },
			],
		},
		{
			text: 'Guides',
			collapsed: false,
			items: [
				{ text: 'Executing Bytecode', link: '/guides/executing-bytecode' },
				{ text: 'State and Storage', link: '/guides/state-and-storage' },
				{ text: 'Calls and Creates', link: '/guides/calls-and-creates' },
				{ text: 'Hardforks', link: '/guides/hardforks' },
				{ text: 'Configuring the EVM', link: '/guides/configuration' },
				{ text: 'Backing State with a Host', link: '/guides/host-interface' },
				{ text: 'Tracing (EIP-3155)', link: '/guides/tracing' },
				{ text: 'Using It from C', link: '/guides/c-ffi' },
				{ text: 'Testing and Debugging', link: '/guides/testing' },
			],
		},
		{
			text: 'Reference',
			collapsed: false,
			items: [
				{ text: 'Module Exports', link: '/reference/module' },
				{ text: 'Evm', link: '/reference/evm' },
				{ text: 'CallParams / CallResult', link: '/reference/call' },
				{ text: 'EvmConfig', link: '/reference/config' },
				{ text: 'Errors', link: '/reference/errors' },
				{ text: 'C API', link: '/reference/c-api' },
				{ text: 'Build Targets', link: '/reference/build-targets' },
			],
		},
		{
			text: 'Ecosystem',
			collapsed: false,
			items: [{ text: 'Where This Fits', link: '/stack' }],
		},
	],
	markdown: {
		code: {
			themes: {
				light: 'github-light',
				dark: 'github-dark',
			},
		},
	},
	banner: {
		dismissable: true,
		content:
			'Guillotine Mini is the readable reference EVM of the [Guillotine](https://guillotine.tevm.sh) family — Berlin through Prague.',
	},
})
