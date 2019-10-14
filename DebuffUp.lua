local debuffTimers = {}
local old_TargetFrame_UpdateAuras = TargetFrame_UpdateAuras;

function DebuffUp_TargetFrame_UpdateAuras(self)
    old_TargetFrame_UpdateAuras(self);

    local frameName, frameCooldown;
    local selfName = self:GetName();
    local frameNum = 1;

    for i = 1, MAX_TARGET_DEBUFFS do
        frameName = selfName.."Debuff"..(i);
        frame = _G[frameName];
        if (not frame) then
            break;
        end
        frameCooldown = _G[frameName.."Cooldown"];
        frameCooldown:SetHideCountdownNumbers(false);
    end
end

-------------------------------------------------------------------------------
-- CARGO CULT ALERT!
-- TargetFrame_UpdateAuraPositions is a lengthy method. It uses some local
-- static constants, so we kinda just have to copy-paste the whole method.
--
-- IMPORTANT! This method has to be kept up-to-date with Blizzard's version. Sadness.
-------------------------------------------------------------------------------

-- aura positioning constants
local AURA_OFFSET_Y = 3;
local LARGE_AURA_SIZE = 32;
local SMALL_AURA_SIZE = 17;
local AURA_ROW_WIDTH = 122;
local NUM_TOT_AURA_ROWS = 2;    -- TODO: replace with TOT_AURA_ROW_HEIGHT functionality if this becomes a problem

function DebuffUp_TargetFrame_UpdateAuraPositions(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX, mirrorAurasVertically)
    -- Position auras
    local size;
    local offsetY = AURA_OFFSET_Y;
    -- current width of a row, increases as auras are added and resets when a new aura's width exceeds the max row width
    local rowWidth = 0;
    local firstBuffOnRow = 1;
    for i=1, numAuras do
        -- update size and offset info based on large aura status
        if ( largeAuraList[i] ) then
            size = LARGE_AURA_SIZE;
            offsetY = AURA_OFFSET_Y + AURA_OFFSET_Y;
        else
            size = SMALL_AURA_SIZE;
        end

        -- anchor the current aura
        if ( i == 1 ) then
            rowWidth = size;
            self.auraRows = self.auraRows + 1;
        else
            rowWidth = rowWidth + size + offsetX;
        end
        if ( rowWidth > maxRowWidth ) then
            -- this aura would cause the current row to exceed the max row width, so make this aura
            -- the start of a new row instead
            updateFunc(self, auraName, i, numOppositeAuras, firstBuffOnRow, size, offsetX, offsetY, mirrorAurasVertically);

            rowWidth = size;
            self.auraRows = self.auraRows + 1;
            firstBuffOnRow = i;
            offsetY = AURA_OFFSET_Y;

            if ( self.auraRows > NUM_TOT_AURA_ROWS ) then
                -- if we exceed the number of tot rows, then reset the max row width
                -- note: don't have to check if we have tot because AURA_ROW_WIDTH is the default anyway
                maxRowWidth = AURA_ROW_WIDTH;
            end
        else
            updateFunc(self, auraName, i, numOppositeAuras, i - 1, size, offsetX, offsetY, mirrorAurasVertically);
        end
    end
end

-------------------------------------------------------------------------------
-- Cargo culting ends here
-------------------------------------------------------------------------------

TargetFrame_UpdateAuras = DebuffUp_TargetFrame_UpdateAuras
TargetFrame_UpdateAuraPositions = DebuffUp_TargetFrame_UpdateAuraPositions
