-- Helper functions for setting window tags
-- ==============================================================================================================================================

local tags = {}

-- Set 'browser' tags and 'chromium'/'firefox' tags
function tags.tag_browser_type()
    local browser_window_classes = {
        chromium = "^(brave-browser|vivaldi-stable)$",
        firefox = "^([Ff]irefox|[Ff]irefox-bin|floorp|zen)$"
    }

    for engine, pattern in pairs(browser_window_classes) do
        hl.window_rule({
            name = "tag-browser-type-" .. engine,
            match = {
                class = pattern
            },
            tag = "+browser"
        })
        if engine == "chromium" then
            hl.window_rule({
                name = "tag-chromium",
                match = {
                    class = pattern
                },
                tag = "+chromium"
            })
        else
            hl.window_rule({
                name = "tag-firefox",
                match = {
                    class = pattern
                },
                tag = "+firefox"
            })
        end
    end
end

-- Tag 'games' and 'gamelauncher' windows
function tags.tag_games()
    -- Gamescope and Steam app windows
    hl.window_rule({
        name = "tag-games",
        match = {
            class = "^(gamescope|steam_app_\\d+)$"
        },
        tag = "+games"
    })

    -- Game launcher windows
    hl.window_rule({
        name = "tag-gamelauncher",
        match = {
            class = "^([Ss]team|net.lutris.Lutris)$"
        },
        tag = "+gamelauncher"
    })
end

-- Tag 'settings' for related apps
function tags.tag_settings()
    local settings_window_classes = {
        kde_settings = "kdesystemsettings",
        network_and_bluetooth = "^(nm-applet|nm-connection-editor|blueman-manager)$",
        audio = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$",
        theme_and_display = "^(qt5ct|qt6ct|nwg-displays|nwg-look|kvantummanager)$",
        desktop_portal = "xdg-desktop-portal-gtk",
        zed_settings = "Zed — Settings"
    }

    for category, pattern in pairs(settings_window_classes) do
        if category == "zed_settings" then
            hl.window_rule({
                name = "tag-settings-" .. category,
                match = {
                    initial_title = pattern
                },
                tag = "+settings"
            })
        else
            hl.window_rule({
                name = "tag-settings-" .. category,
                match = {
                    class = pattern
                },
                tag = "+settings"
            })
        end
    end
end

return tags
