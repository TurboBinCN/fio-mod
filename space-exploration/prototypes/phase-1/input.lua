local data_util = require("data_util")

data:extend{
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'remote-view-pins',
        key_sequence = "CONTROL + SHIFT + N",
        enabled_while_spectating = true,
        order = "a-aa"
    },
    -- {
    --     type = 'custom-input',
    --     name = data_util.mod_prefix .. 'remote-view-next',
    --     key_sequence = 'SHIFT + N',
    --     enabled_while_spectating = true,
    --     order = "a-ab"
    -- },
    -- {
    --     type = 'custom-input',
    --     name = data_util.mod_prefix .. 'remote-view-previous',
    --     key_sequence = 'CONTROL + N',
    --     enabled_while_spectating = true,
    --     order = "a-ac"
    -- },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'star-map',
        key_sequence = 'Y',
        enabled_while_spectating = true,
        order = "a-b",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'universe-explorer',
        key_sequence = 'U',
        enabled_while_spectating = true,
        order = "a-c",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'respawn',
        key_sequence = "HOME",
        enabled_while_spectating = true,
        order = "a-d",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'mode-toggle',
        key_sequence = "R",
        enabled_while_spectating = true,
        order = "a-e",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'blueprint-converter',
        key_sequence = "",
        enabled_while_spectating = true,
        order = "a-f",
    },
    -- pin to pin hotkeys
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-one',
        key_sequence = "CONTROL + 1",
        enabled_while_spectating = true,
        order = "b-a",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-two',
        key_sequence = "CONTROL + 2",
        enabled_while_spectating = true,
        order = "b-b",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-three',
        key_sequence = "CONTROL + 3",
        enabled_while_spectating = true,
        order = "b-c",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-four',
        key_sequence = "CONTROL + 4",
        enabled_while_spectating = true,
        order = "b-d",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-five',
        key_sequence = "CONTROL + 5",
        enabled_while_spectating = true,
        order = "b-e",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-six',
        key_sequence = "CONTROL + 6",
        enabled_while_spectating = true,
        order = "b-f",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-seven',
        key_sequence = "CONTROL + 7",
        enabled_while_spectating = true,
        order = "b-g",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-eight',
        key_sequence = "CONTROL + 8",
        enabled_while_spectating = true,
        order = "b-h",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-nine',
        key_sequence = "CONTROL + 9",
        enabled_while_spectating = true,
        order = "b-i",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-zero',
        key_sequence = "CONTROL + 0",
        enabled_while_spectating = true,
        order = "b-j",
    },
    -- set pin hotkeys
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-set-one',
        key_sequence = "CONTROL + SHIFT + 1",
        enabled_while_spectating = true,
        order = "c-a",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-set-two',
        key_sequence = "CONTROL + SHIFT + 2",
        enabled_while_spectating = true,
        order = "c-b",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-set-three',
        key_sequence = "CONTROL + SHIFT + 3",
        enabled_while_spectating = true,
        order = "c-c",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-set-four',
        key_sequence = "CONTROL + SHIFT + 4",
        enabled_while_spectating = true,
        order = "c-d",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-set-five',
        key_sequence = "CONTROL + SHIFT + 5",
        enabled_while_spectating = true,
        order = "c-e",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-set-six',
        key_sequence = "CONTROL + SHIFT + 6",
        enabled_while_spectating = true,
        order = "c-f",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-set-seven',
        key_sequence = "CONTROL + SHIFT + 7",
        enabled_while_spectating = true,
        order = "c-g",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-set-eight',
        key_sequence = "CONTROL + SHIFT + 8",
        enabled_while_spectating = true,
        order = "c-h",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-set-nine',
        key_sequence = "CONTROL + SHIFT + 9",
        enabled_while_spectating = true,
        order = "c-i",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. 'pin-set-zero',
        key_sequence = "CONTROL + SHIFT + 0",
        enabled_while_spectating = true,
        order = "c-j",
    },
    {
        type = 'custom-input',
        name = data_util.mod_prefix .. '-targeter',
        key_sequence = "",
        -- artillery targeting remote is a capsule - capsules use the build hotkey
        linked_game_control = "build"
    },
    -- linked game controls
    {
        type = "custom-input",
        name = data_util.mod_prefix .. 'focus-search',
        key_sequence = "",
        linked_game_control = "focus-search"
    },
    {
        type = "custom-input",
        name = data_util.mod_prefix .. "confirm",
        key_sequence = "",
        linked_game_control = "confirm-gui"
    },
    {
        type = "custom-input",
        name = data_util.mod_prefix .. "next-zone",
        key_sequence = "",
        linked_game_control = "next-surface"
    },
    {
        type = "custom-input",
        name = data_util.mod_prefix .. "previous-zone",
        key_sequence = "",
        linked_game_control = "previous-surface"
    }
}
