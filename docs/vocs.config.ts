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
		'A minimal, readable Ethereum Virtual Machine in Zig — Frontier through Osaka, native C ABI, and a WASI Preview 1 WebAssembly reactor with linked crypto.',
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
	checkDeadlinks: true,
	editLink: {
		link: 'https://github.com/evmts/guillotine-mini/edit/main/docs/:path',
		text: 'Edit on GitHub',
	},
	topNav: [
		{ text: 'Tutorials', link: '/getting-started', match: '/tutorials' },
		{ text: 'Guides', link: '/guides/calls-and-creates', match: '/guides' },
		{ text: 'Reference', link: '/reference/evm', match: '/reference' },
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
			text: 'Start Here',
			collapsed: false,
			items: [
				{ text: 'Overview', link: '/' },
				{ text: 'Getting Started', link: '/getting-started' },
				{ text: 'Architecture', link: '/architecture' },
				{ text: 'Opcode & Gas Explorer', link: '/opcode-explorer' },
			],
		},
		{
			text: 'Tutorials',
			collapsed: false,
			items: [
				{ text: '1. Your First Contract Call', link: '/tutorials/first-call' },
				{ text: '2. State, Storage & Snapshots', link: '/tutorials/state-and-snapshots' },
				{ text: '3. Building a Custom Host', link: '/tutorials/custom-host' },
				{ text: '4. Running in WebAssembly', link: '/tutorials/webassembly' },
			],
		},
		{
			text: 'Guides',
			collapsed: false,
			items: [
				{ text: 'Calls, Delegatecall & Create', link: '/guides/calls-and-creates' },
				{ text: 'Hardforks & EIPs', link: '/guides/hardforks' },
				{ text: 'Configuring & Extending', link: '/guides/configuration' },
				{ text: 'Tracing & Inspectors', link: '/guides/tracing' },
				{ text: 'Observability, Simulation & RPC', link: '/guides/observability-and-rpc' },
				{ text: 'C FFI & Async State Injection', link: '/guides/c-ffi' },
				{ text: 'Building & Testing', link: '/guides/testing' },
			],
		},
		{
			text: 'Reference',
			collapsed: false,
			items: [
				{ text: 'Module Exports', link: '/reference/module' },
				{ text: 'Evm & Frame', link: '/reference/evm' },
				{ text: 'CallParams & CallResult', link: '/reference/call' },
				{ text: 'EvmConfig & HostInterface', link: '/reference/config' },
				{ text: 'Errors', link: '/reference/errors' },
				{ text: 'C & WASM ABI', link: '/reference/c-api' },
				{ text: 'Build Targets', link: '/reference/build-targets' },
			],
		},
		{
			text: 'Ecosystem',
			collapsed: false,
			items: [{ text: 'The Tevm Stack', link: '/stack' }],
		},
	],
	banner: {
		dismissable: true,
		content:
			'Guillotine Mini is the readable reference EVM of the [Guillotine](https://guillotine.tevm.sh) family — Frontier through Osaka, native Zig & WASI WASM.',
	},
})
