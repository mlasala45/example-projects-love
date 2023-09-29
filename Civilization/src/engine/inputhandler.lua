InputHandler = {}

InputHandler.GeneralKeypressHandlers = {}
InputHandler.GeneralKeypressHandlers_Priority = {}

InputHandler.KeypressHandlers = {}
InputHandler.KeypressHandlers_Priority = {}

InputHandler.ClickHandlers = {}
InputHandler.ScrollHandlers = {}
InputHandler.TextHandlers = {}

function InputHandler:OnKeypress(key, scancode, isrepeat)
	local disable_further_handling = false

	for i,v in ipairs(InputHandler.GeneralKeypressHandlers_Priority) do
		local ret = v(key,isrepeat)
		if ret then disable_further_handling = true end
	end

	for i,v in ipairs(InputHandler.KeypressHandlers_Priority[key] or {}) do
		local ret = v(isrepeat)
		if ret then disable_further_handling = true end
	end

	if disable_further_handling then return end


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

function InputHandler:OnTextEntered(char)
	for i,v in ipairs(InputHandler.TextHandlers) do
		v(char)
	end
end

function InputHandler:AddGeneralKeypressHandler(fn, priority)
	if priority then
		table.insert(InputHandler.GeneralKeypressHandlers_Priority, fn)
	else
		table.insert(InputHandler.GeneralKeypressHandlers, fn)
	end
	return fn
end

function InputHandler:AddKeypressHandler(key, fn, priority)
	local t = InputHandler.KeypressHandlers
	if priority then t = InputHandler.KeypressHandlers_Priority end

	t[key] = t[key] or {}
	table.insert(t[key], fn)
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

function InputHandler:AddTextHandler(fn)
	table.insert(InputHandler.TextHandlers, fn)
	return fn
end

function InputHandler:RemoveGeneralKeypressHandler(fn)
	local t = InputHandler.GeneralKeypressHandlers
	if not table.contains(t, fn) then return end
	table.remove(t, table.find(t, fn))

	t = InputHandler.GeneralKeypressHandlers_Priority
	if not table.contains(t, fn) then return end
	table.remove(t, table.find(t, fn))
end

function InputHandler:RemoveKeypressHandler(key, fn)
	local t = InputHandler.KeypressHandlers[key]
	if not table.contains(t, fn) then return end
	table.remove(t, table.find(t, fn))

	t = InputHandler.KeypressHandlers_Priority[key]
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

function InputHandler:RemoveTextHandler(fn)
	local t = InputHandler.TextHandlers
	if not table.contains(t, fn) then return end
	table.remove(t, table.find(t, fn))
end