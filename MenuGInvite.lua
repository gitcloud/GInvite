-- 1. Register the string name globally so the 3.3.5a UI engine can look up the text
UnitPopupButtons["REBEL_GUILD_INVITE"] = { text = "Invite to Guild", dist = 0 }

-- 2. Inject the button directly into the static 3.3.5a menu layout tables
local menusToModify = { "CHAT_ROSTER", "PLAYER", "TARGET", "PARTY", "WHO" }
for _, menuName in ipairs(menusToModify) do
    if UnitPopupMenus[menuName] then
        table.insert(UnitPopupMenus[menuName], #UnitPopupMenus[menuName], "REBEL_GUILD_INVITE")
    end
end

-- 3. Prevent the 3.3.5a engine from wiping our button during UI updates
hooksecurefunc("UnitPopup_HideButtons", function()
    local dropdownMenu = UIDROPDOWNMENU_INIT_MENU
    if dropdownMenu and dropdownMenu.which then
        local which = dropdownMenu.which
        -- Double check that our button isn't accidentally scrubbed out by the engine
        if UnitPopupMenus[which] then
            local hasButton = false
            for _, val in ipairs(UnitPopupMenus[which]) do
                if val == "REBEL_GUILD_INVITE" then
                    hasButton = true
                    break
                end
            end
            if not hasButton then
                table.insert(UnitPopupMenus[which], #UnitPopupMenus[which], "REBEL_GUILD_INVITE")
            end
        end
    end
end)

-- 4. Overwrite click handler using 3.3.5a specific arguments
local orig_UnitPopup_OnClick = UnitPopup_OnClick
UnitPopup_OnClick = function(self, ...)
    -- 3.3.5a OnClick passes 'button' name via macro evaluation context
    local button = self.value 
    local dropdownFrame = UIDROPDOWNMENU_INIT_MENU
    
    if button == "REBEL_GUILD_INVITE" and dropdownFrame then
        local name = dropdownFrame.name
        
        -- Fallback fallback string check specifically for WotLK Who Frame selections
        if not name and WhoFrame and WhoFrame.selectedName and WhoFrame:IsShown() then
            name = WhoFrame.selectedName
        end
        
        -- Run game system invite functions safely
        if name and CanGuildInvite() then
            GuildInvite(name)
        end
        return
    end
    
    -- Pass control seamlessly back to the default Blizzard UI engine
    return orig_UnitPopup_OnClick(self, ...)
end
