local SLAXML = require 'util/slaxdom'
require "util/DataDumper"

local function getChild(parent, name)
	local t =  parent.kids
	for i,v in ipairs(t) do
		if v and v.name == name then return v end
	end
	return nil
end

local function extractCardData(card)
	local fields = { 'name', 'color', 'manacost', 'type', 'text' }

	local dataOut = {}
	for _,key in ipairs(fields) do
		local fieldData = getChild(card, key)
		if fieldData and #fieldData.kids > 0 then
			dataOut[key] = fieldData.kids[1].value
		end
	end
	return dataOut
end

CARD_SETS = {}

function LoadCardSet(filename)
	local setname = string.match(filename, "(.*).xml")
	local xml_content = love.filesystem.read("data/"..filename)
	
	local xmldoc = SLAXML:dom(xml_content)

	local rootNode = xmldoc.root
	local node_cards = getChild(rootNode, "cards")
	--print(node_cards.name.."    numChildren: "..#node_cards.el)
	local card = node_cards.el[1]


	local set = {}

	local numCards = 0
	for _,card in ipairs(node_cards.el) do
		local data = extractCardData(card)
		set[data.name] = data
		numCards = numCards + 1
	end
	CARD_SETS[setname] = set

	p_print(string.format("Registered %s Cards from set '%s'",numCards, setname))
	--p_print(rootNode.nodeName.."    "..rootNode.nodeValue)
end