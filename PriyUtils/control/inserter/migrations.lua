return function(env, old_version)
    if old_version == '0.1.3' then
        for _, player in pairs(game.players) do
            env.init_toggle_button(player)
        end
    end
end