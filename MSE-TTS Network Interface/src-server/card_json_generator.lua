local json = require "util/json"

function GenerateCardJSON(setName, dataIn)
	local data = {
		object = "card",
		id = "c8212667-7e18-42a5-9f36-4f8a6ad12f83",
		--oracle_id = "b81eaa2f-0554-41c6-bdf6-d1cb73b8f56f",
		multiverse_ids = { 503804 },
		--mtgo_id = 87719,
		--arena_id = 75235,
		--tcgplayer_id = 229251,
		--cardmarket_id = 527505,
		name = "Realmwalker",
		lang = "en",
		--released_at = "2021-02-05",
		--uri = "https://api.scryfall.com/cards/c8212667-7e18-42a5-9f36-4f8a6ad12f83",
		--scryfall_uri = "https://scryfall.com/card/khm/188/realmwalker?utm_source=api",
		layout = "normal",
		highres_image = true,
		image_status = "highres_scan",
		image_uris = {
			--small = "https://c1.scryfall.com/file/scryfall-cards/small/front/c/8/c8212667-7e18-42a5-9f36-4f8a6ad12f83.jpg?1614989460",
			--normal = "https://c1.scryfall.com/file/scryfall-cards/normal/front/c/8/c8212667-7e18-42a5-9f36-4f8a6ad12f83.jpg?1614989460",
			large = string.format("http://%s:12345/images/7.png?THISSUFFIXISREQUIRED",BINDING_IP),--"https://c1.scryfall.com/file/scryfall-cards/large/front/c/8/c8212667-7e18-42a5-9f36-4f8a6ad12f83.jpg?1614989460",
			--png = "https://c1.scryfall.com/file/scryfall-cards/png/front/c/8/c8212667-7e18-42a5-9f36-4f8a6ad12f83.png?1614989460",
			--art_crop = "https://c1.scryfall.com/file/scryfall-cards/art_crop/front/c/8/c8212667-7e18-42a5-9f36-4f8a6ad12f83.jpg?1614989460",
			--border_crop = "https://c1.scryfall.com/file/scryfall-cards/border_crop/front/c/8/c8212667-7e18-42a5-9f36-4f8a6ad12f83.jpg?1614989460"
		},
		mana_cost = "{2}{G}",
		cmc = 3.0,
		type_line = "Creature — Shapeshifter",
		oracle_text = [[Changeling (This card is every creature type.)
As Realmwalker enters the battlefield, choose a creature type.
You may look at the top card of your library any time.
You may cast creature spells of the chosen type from the top of your library.]],
		--power = "2",
		--toughness = "3",
		colors = { "G" },
		color_identity = { "G" },
		keywords = { "Changeling" },
		--[[legalities = {
			standard = "legal",
			future = "legal",
			historic = "legal",
			gladiator = "legal",
			pioneer = "legal",
			modern = "legal",
			legacy = "legal",
			pauper = "not_legal",
			vintage = "legal",
			penny = "not_legal",
			commander = "legal",
			brawl = "legal",
			duel = "legal",
			oldschool = "not_legal",
			premodern = "not_legal"
		},
		games = { "arena", "paper", "mtgo" },]]
		--[[reserved = false,
		foil = true,
		nonfoil = true,
		oversized = false,
		promo = false,
		reprint = false,
		variation = false,
		set = "khm",
		set_name = "Kaldheim",
		set_type = "expansion",
		set_uri = "https://api.scryfall.com/sets/43057fad-b1c1-437f-bc48-0045bce6d8c9",
		set_search_uri = "https://api.scryfall.com/cards/search?order=set&q=e%3Akhm&unique=prints",
		scryfall_set_uri = "https://scryfall.com/sets/khm?utm_source=api",
		rulings_uri = "https://api.scryfall.com/cards/c8212667-7e18-42a5-9f36-4f8a6ad12f83/rulings",
		prints_search_uri = "https://api.scryfall.com/cards/search?order=released&q=oracleid%3Ab81eaa2f-0554-41c6-bdf6-d1cb73b8f56f&unique=prints",
		collector_number = "188",
		digital = false,
		rarity = "rare",
		card_back_id = "0aeebaf5-8c7d-4636-9e82-8c27447861f7",
		artist = "Zack Stella",
		artist_ids = { "17bc7f55-958b-43f4-bb40-09746d05b3f9" },
		illustration_id = "3c3713dd-e54c-463a-86cc-10241bb1c7ba",
		border_color = "black",
		frame = "2015",
		full_art = false,
		textless = false,
		booster = true,
		story_spotlight = false,
		edhrec_rank = 4919,
		preview = {
			source = "Rhapsody of Fire",
			source_uri = "https://www.instagram.com/p/CI3wqLtn659/",
			previewed_at = "2020-12-16"
		},
		prices = {
			usd = "3.58",
			usd_foil = "3.66",
			eur = "3.17",
			eur_foil = "3.35",
			tix = "0.76"
		},
		related_uris = {
			gatherer = "https://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=503804",
			tcgplayer_infinite_articles = "https://infinite.tcgplayer.com/search?contentMode=article&game=magic&partner=scryfall&q=Realmwalker&utm_campaign=affiliate&utm_medium=api&utm_source=scryfall",
			tcgplayer_infinite_decks = "https://infinite.tcgplayer.com/search?contentMode=deck&game=magic&partner=scryfall&q=Realmwalker&utm_campaign=affiliate&utm_medium=api&utm_source=scryfall",
			edhrec = "https://edhrec.com/route/?cc=Realmwalker",
			mtgtop8 = "https://mtgtop8.com/search?MD_check=1&SB_check=1&cards=Realmwalker"
		},
		purchase_uris = {
			tcgplayer = "https://shop.tcgplayer.com/product/productsearch?id=229251&utm_campaign=affiliate&utm_medium=api&utm_source=scryfall",
			cardmarket = "https://www.cardmarket.com/en/Magic/Products/Singles/Kaldheim/Realmwalker?referrer=scryfall&utm_campaign=card_prices&utm_medium=text&utm_source=scryfall",
			cardhoarder = "https://www.cardhoarder.com/cards/87719?affiliate_id=scryfall&ref=card-profile&utm_campaign=affiliate&utm_medium=card&utm_source=scryfall"
		}]]
	}

	--[[local large = data.image_uris.large
	data.image_uris.small = large
	data.image_uris.normal = large
	data.image_uris.png = large
	data.image_uris.art_crop = large
	data.image_uris.border_crop = large
	]]

	--Needs override:
	--name
	--image_uris.large
	--oracle_text

	--cmc

	local img_ip = "localhost" --BINDING_IP

	data.name = dataIn.name
	data.image_uris.large = string.format("http://%s:%s/images/%s/%s.png?THISSUFFIXISREQUIRED",img_ip, BINDING_PORT,setName,dataIn.name)
	data.image_uris.large = data.image_uris.large:gsub(" ", "%%20")
	data.oracle_text = dataIn.text or ""


	print("Image URI: "..data.image_uris.large)

	return json.encode(data)
end