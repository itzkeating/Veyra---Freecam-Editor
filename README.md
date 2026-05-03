# Veyra Freecam Editor

A FiveM resource that adds an **orbital freecam** with optional **Discord screenshot uploads**, plus an **in-game image editor** (adjustments, effects, and temporary hosting via Litterbox).

**Copyright © Veyra Studios.** All files in this product—including Lua scripts, HTML/CSS/JS, manifests, and related assets—are owned by **Veyra Studios**. Redistribution, resale, or modification outside your licensed use requires permission from Veyra Studios.

---

## Requirements

- **FiveM** server (or single-player testing via equivalent tooling).
- **`screenshot-basic`** resource installed and started **before** this resource (declared as a dependency in `fxmanifest.lua`).

---

## Installation

1. Copy this folder into your server `resources` directory (or keep it in your development workspace).
2. Ensure **`screenshot-basic`** is available on the server.
3. Add to `server.cfg`:

   ```cfg
   ensure screenshot-basic
   ensure <your-resource-folder-name>
   ```

4. Configure your Discord webhook (see below), then restart the resource or server.

---

## Usage

| Command    | Action |
|-----------|--------|
| `/editor` | Toggle freecam on/off |
| `/editorui` | Open the image editor NUI |

**Freecam controls** (shown in the HUD): movement, zoom, screenshot (**Enter**), exit (**Esc**), etc.

---

## Changing the Discord webhook

Webhook settings live in **`veyra_webhook.lua`** (loaded as a `shared_script` so both client uploads and server branding stay in sync).

Edit the `VeyraWebhook` table:

```lua
VeyraWebhook = {
    execute_url = "https://discord.com/api/webhooks/<WEBHOOK_ID>/<WEBHOOK_TOKEN>?wait=true",

    display_name = "Veyra Freecam",
.
    avatar_source_url = "https://…",
}
```

### What each field does

- **`execute_url`** — Used by **`client.lua`** when uploading freecam screenshots through **`screenshot-basic`**. Use your channel’s **Incoming Webhook** URL from Discord; append **`?wait=true`** so Discord returns JSON including attachment URLs.
- **`display_name`** / **`avatar_source_url`** — On resource start, **`server.lua`** can sync the webhook’s **default name and avatar** via Discord’s API so incoming screenshots match your branding.

### Security note

The webhook URL contains a **secret token**. Anyone who has your resource files can see it—do **not** ship this resource to untrusted players as client-readable Lua unless you accept that risk. Prefer restricting repo access and rotating webhooks if a leak occurs.

---

## Resource layout (overview)

| Path | Role |
|------|------|
| `fxmanifest.lua` | Resource manifest |
| `veyra_webhook.lua` | **Webhook & branding configuration** |
| `client.lua` | Freecam logic & screenshot upload trigger |
| `server.lua` | Server-side webhook branding sync |
| `ui.lua` | Small client hooks |
| `html/` | NUI editor (`index.html`, `style.css`, `script.js`) |

Some shipped Lua/HTML/JS may be **encrypted or packed** for distribution; functionality is unchanged at runtime. Editing those files directly may require the original sources from **Veyra Studios**.

---

## Support & branding

- Community / links shown in the UI (e.g. Discord) are configured in the NUI sources as provided by **Veyra Studios**.
- For licensing, custom builds, or white-label terms, contact **Veyra Studios**.

---

*Veyra Studios — Veyra Freecam Editor*
