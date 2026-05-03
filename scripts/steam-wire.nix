# modules/features/steam-wire.nix
#
# Home Manager module – imported directly inside home.nix's
# home-manager.users.moara block. No nixosModule entry needed.
#
# What it does: when a Proton/Wine game (wine64-preloader) starts, this
# WirePlumber script disconnects Steam's game-recording input from the
# system audio sink and wires the game's own audio stream to it instead,
# so Steam only records game audio rather than everything on the desktop.
#
# Source / credit: https://github.com/Widowan/steam-wire (MIT)
# Script reconstructed from the author's own blog post:
# https://blog.wido.dev/wireplumber-scripting
{ ... }:
{
  # ── WirePlumber component declaration ────────────────────────────────────
  xdg.configFile."wireplumber/wireplumber.conf.d/90-steam-wire.conf".text = ''
    wireplumber.components = [
      {
        name     = steam-wire.lua,
        type     = script/lua,
        provides = custom.steam-wire
      }
    ]

    wireplumber.profiles = {
      main = {
        custom.steam-wire = required
      }
    }
  '';

  # ── Lua script ────────────────────────────────────────────────────────────
  # WirePlumber's sandbox garbage-collects locals after the first run, so
  # every ObjectManager that must survive across callbacks is intentionally
  # kept as a global.
  home.file.".local/share/wireplumber/scripts/steam-wire.lua".text = ''
    -- steam-wire.lua
    -- Redirect Steam game recording to listen to the Proton/Wine game only.
    -- Source: https://github.com/Widowan/steam-wire

    log = Log.open_topic("s-steam-wire")

    -- Link two PipeWire ports.
    -- input_port  = consuming side (Steam recorder)
    -- output_port = producing side (Wine/Proton game audio)
    function link_ports(input_port, output_port)
      if not input_port or not output_port then
        log:warning("nil values, not linking")
        return
      end

      local link_args = {
        ["link.input.node"]  = input_port.properties["node.id"],
        ["link.input.port"]  = input_port.properties["object.id"],
        ["link.output.node"] = output_port.properties["node.id"],
        ["link.output.port"] = output_port.properties["object.id"],
        ["object.id"]        = nil,
        ["object.linger"]    = true,
        ["node.description"] = "Link created by steam-wire",
      }

      local link = Link("link-factory", link_args)
      link:activate(1)
    end

    -- Reusable Interest for port-direction filtering inside iterate_ports().
    input_ports = Interest {
      type = "port",
      Constraint { "port.direction", "equals", "in" },
    }

    -- ── Steam recording nodes ───────────────────────────────────────────────
    -- Steam's game recorder registers itself as a Stream/Input/Audio node.
    steam_om = ObjectManager {
      Interest {
        type = "node",
        Constraint { "application.process.binary", "matches", "steam",              type = "pw" },
        Constraint { "media.class",                "matches", "Stream/Input/Audio", type = "pw" },
      },
    }

    -- For every Steam recording node, tear down any Audio/Sink link
    -- (that is the whole system-audio mix) feeding into it.
    steam_om:connect("object-added", function(_, steam_node)

      steam_link_om = ObjectManager {
        Interest {
          type = "link",
          Constraint { "link.input.node", "equals", steam_node.properties["object.id"] },
        }
      }

      steam_link_om:connect("object-added", function(_, steam_link)

        steam_source_om = ObjectManager {
          Interest {
            type = "node",
            Constraint { "object.id",   "equals", steam_link.properties["link.output.node"] },
            Constraint { "media.class", "matches", "Audio/Sink*" },
          }
        }

        -- Confirm the source is actually a sink, then destroy the link.
        steam_source_om:connect("object-added", function(_, _source_node)
          local _, err = pcall(function() steam_link:request_destroy() end)
          if err then log:debug("Destroying error: " .. tostring(err)) end
        end)

        steam_source_om:activate()
      end)

      steam_link_om:activate()
    end)

    -- ── Wine/Proton game nodes ──────────────────────────────────────────────
    wine_om = ObjectManager {
      Interest {
        type = "node",
        Constraint { "application.process.binary", "matches", "wine64-preloader",    type = "pw" },
        Constraint { "media.class",                "matches", "Stream/Output/Audio", type = "pw" },
      },
    }

    -- For each Wine game node, wait for its output ports to appear
    -- (FFXIV and similar titles can be slow to expose them), then
    -- wire each matching channel into Steam's recorder.
    wine_om:connect("object-added", function(_, wine_node)

      wine_port_om = ObjectManager {
        Interest {
          type = "port",
          Constraint { "node.id",        "equals", wine_node.properties["object.id"] },
          Constraint { "port.direction", "equals", "out" },
        }
      }

      wine_port_om:connect("object-added", function(_, wine_port)
        for steam_node in steam_om:iterate() do
          for steam_port in steam_node:iterate_ports(input_ports) do
            if steam_port.properties["audio.channel"] == wine_port.properties["audio.channel"] then
              link_ports(steam_port, wine_port)
            end
          end
        end
      end)

      wine_port_om:activate()
    end)

    steam_om:activate()
    wine_om:activate()
  '';
}
