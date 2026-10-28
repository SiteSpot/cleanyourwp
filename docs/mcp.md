# Agent access and the MCP Adapter

As of October 2026. Verify against [wordpress.org/plugins/mcp-adapter](https://wordpress.org/plugins/mcp-adapter/) and [github.com/WordPress/mcp-adapter](https://github.com/WordPress/mcp-adapter) before relying on details; this area moves.

## What it is

WordPress 6.9 added the Abilities API to core: a standard way for core, plugins and themes to register named capabilities ("get posts", "update a setting") with a schema. The MCP Adapter is an official WordPress.org plugin that exposes those abilities to AI agents over the Model Context Protocol, through the REST API, so an agent can discover what the site can do and call it.

The adapter is transport only. It has no AI features and exposes nothing until abilities are registered and marked public.

## Requirements

- WordPress 6.9 or newer (the standalone Abilities API plugin is no longer a supported path).
- PHP 7.4 or newer (use a supported PHP anyway; see the prompt).
- HTTPS, and a way to authenticate: application passwords work for the REST transport.

## How the prompt treats it

- **Phase 0:** if the adapter is already installed and you give the agent an endpoint and token, it uses it for the audit. It never installs the adapter to improve its own access.
- **Phase 4:** the "agent access" score rewards a deliberate setup (adapter installed, abilities exposed on purpose, token scoped to a dedicated user and logged) and treats "no agent access yet" as fine when you have no use for it.
- **Phase 5:** asks whether you want agents to work with the site: read and write, read only, not yet, never.
- **Phase 6:** installing and configuring it is plan item 10, only if you said yes.

## A sensible setup when you do want it

1. A dedicated WordPress user for agents, with the lowest role that covers what they need. Not an administrator unless an ability needs it.
2. One application password or MCP token per agent, named after the agent, so you can revoke one without touching the others.
3. Expose abilities deliberately. Start with read abilities; add write abilities per use case.
4. Log what agents do. A simple activity-log plugin, or the host's access logs filtered by the agent user.
5. Rotate tokens quarterly (it's on the keep-it-clean checklist).

Core application passwords inherit the dedicated user's capabilities. They do not independently restrict endpoints, create a read-only scope, or expire automatically. Enforce authorization in each exposed ability and choose the user's role accordingly; a token name is only a label.

## Alternatives

- **REST API with an application password**: available since WordPress 5.6, no plugin needed. Agents get the standard endpoints (posts, media, users, settings). Good enough for most content work; less discoverable than MCP.
- **WP-CLI over SSH**: the strongest access, and what the audit prefers. Not something you hand to a third-party agent.
