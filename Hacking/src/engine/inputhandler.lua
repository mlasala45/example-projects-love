InputHandler = {}

InputHandler.GeneralKeypressHandlers = {}
InputHandler.KeypressHandlers = {}
InputHandler.ClickHandlers = {}
InputHandler.ScrollHandlers = {}

function InputHandler:OnKeypress(key, scancode, isrepeat)
	for i,v in ipairs(InputHandler.GeneralKeypressHandlers) do
		v(key,isrepeat)
	end
	for i,v in ipairs(InputHandler.KeypressHandlers[key] or {}) do
		v(isrepeat)
	end
end

function InputHandler:OnClick(x, y, button, istouch)
	for i,v in ipairs(InputHandler.ClickHandlers) do
		v(x, y, button)
	end
end

function InputHandler:OnScroll(n)
	for i,v in ipairs(InputHandler.ScrollHandlers) do
		v(n)
	end
end

function InputHandler:AddGeneralKeypressHandler(fn)
	table.insert(InputHandler.GeneralKeypressHandlers, fn)
	return fn
end

function InputHandler:AddKeypressHandler(key, fn)
	InputHandler.KeypressHandlers[key] = InputHandler.KeypressHandlers[key] or {}
	table.insert(InputHandler.KeypressHandlers[key], fn)
	return fn
end

function InputHandler:AddClickHandler(fn)
	table.insert(InputHandler.ClickHandlers, fn)
	return fn
end

function InputHandler:AddScrollHandler(fn)
	table.insert(InputHandler.ScrollHandlers, fn)
	return fn
end

function InputHandler:RemoveGeneralKeypressHandler(fn)
	local t = InputHandler.GeneralKeypressHandlers
	if not table.contains(t, fn) then return end
	table.remove(t, table.find(t, fn))
end

function InputHandler:RemoveKeypressHandler(key, fn)
	local t = InputHandler.KeypressHandlers[key]
	if not table.contains(t, fn) then return end
	table.remove(t, table.find(t, fn))
end

function InputHandler:RemoveClickHandler(fn)
	local t = InputHandler.ClickHandlers
	if not table.contains(t, fn) then return end
	table.remove(t, table.find(t, fn))
end

function InputHandler:RemoveScrollHandler(fn)
	local t = InputHandler.ScrollHandlers
	if not table.contains(t, fn) then return end
	table.remove(t, table.find(t, fn))
end