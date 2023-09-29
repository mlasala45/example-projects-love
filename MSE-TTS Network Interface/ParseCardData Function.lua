-- Parses scryfall response data for a card.
-- Returns a populated card table and a list of tokens.
local function parseCardData(cardID, data)
    local tokens = {}
    local tokenData = {}

    local function addToken(name, scryfallID, uri, shortName)
        -- Add it to the tokens list
        table.insert(tokens, {
            name = name,
            scryfallID = scryfallID
        })

        -- Query for token data and save it on the card for later
        WebRequest.get(uri, function(webReturn)
            if webReturn.is_error or webReturn.error or string.len(webReturn.text) == 0 then
                log(\"Error: \" ..webReturn.error or \"unknown\")
                return
            end

            local success, data = pcall(function() return JSON.decode(webReturn.text) end)
            if not success or not data or data.object == \"error\" then
                log(\"Error: JSON Parse\")
                return
            end

            table.insert(tokenData, {
                name = shortName or name,
                desc = collectOracleText(data),
                front = pickImageURI(data),
                back = getCardBack()
            })
        end)
    end

    -- On normal cards, check for tokens or related effects (i.e. city's blessing)
    if data.all_parts and not (data.layout == \"token\" or data.type_line == \"Card\") then
        for _, part in ipairs(data.all_parts) do
            if part.component and (part.type_line == \"Card\" or part.component == \"token\") then
                addToken(part.name, part.id, part.uri)
            elseif part.component and (string.sub(part.type_line,1,6) == \"Emblem\" and not (string.sub(data.type_line,1,6) == \"Emblem\")) then
                addToken(part.name, part.id, part.uri, \"Emblem\")
            end
        end
    end

    local card = shallowCopyTable(cardID)
    card.name = getAugmentedName(data)
    card.oracleText = collectOracleText(data)
    card.faces = {}
    card.scryfallID = data.id
    card.oracleID = data.oracle_id
    card.language = data.lang
    card.setCode = data.set
    card.collectorNum = data.collector_number

    if data.layout == \"transform\" or data.layout == \"art_series\" or data.layout == \"double_sided\" or data.layout == \"modal_dfc\" or data.layout == \"double_faced_token\" then
        for i, face in ipairs(data.card_faces) do
            card['faces'][i] = {
                imageURI = pickImageURI(face, data.highres_image, data.image_status),
                name = getAugmentedName(face),
                oracleText = card.oracleText,
                tokenData = tokenData
            }
        end
    else
        card['faces'][1] = {
            imageURI = pickImageURI(data),
            name = card.name,
            oracleText = card.oracleText,
            tokenData = tokenData
        }
    end

    return card, tokens
end