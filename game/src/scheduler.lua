local Scheduler = {
	enqueuedCommands = {},

	commands = {},
	promises = {},
}

function Scheduler:enqueue(commandFunc, ...)
	local command = coroutine.create(commandFunc)
	local promise = {done = false}
	local succ, result = coroutine.resume(command, ...)

	if (not succ) then
		print(result)
	end

	if (coroutine.status(command) ~= "dead") then
		table.insert(self.enqueuedCommands, command)
		self.promises[command] = promise
	else
		promise.result = result
		promise.done = true
	end

	return promise
end

function Scheduler:waitFor(commandFunc, ...)
	local promise = self:enqueue(commandFunc, ...)
	while (not promise.done) do
		coroutine.yield()
	end
	return promise.result
end

function Scheduler:waitForP(promise)
	while (not promise.done) do
		coroutine.yield()
	end
	return promise.result
end

function Scheduler:waitForFlux(tween)
	local done = false
	tween:oncomplete(function()
		done = true
	end)
	while (not done) do
		coroutine.yield()
	end
end


function Scheduler:update()
	for i = #self.commands, 1, -1 do
		local command = self.commands[i]

		local succ, result = coroutine.resume(command)
		if (not succ) then
			print(result)
		end

		if (coroutine.status(command) == "dead") then
			table.remove(self.commands, i)
			self.promises[command].done = true
			self.promises[command].result = result
			self.promises[command] = nil
		end
	end

	for i = #self.enqueuedCommands, 1, -1 do
		local command = self.enqueuedCommands[i]
		table.insert(self.commands, command)
		self.enqueuedCommands[i] = nil
	end
end

return Scheduler