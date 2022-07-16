local CommandSequencer = {
	enqueuedCommands = {},

	commands = {},
	promises = {},
}

function CommandSequencer:enqueue(commandFunc, ...)
	local command = coroutine.create(commandFunc)
	local promise = {done = false}
	coroutine.resume(command, ...)

	if (coroutine.status(command) ~= "dead") then
		table.insert(self.enqueuedCommands, command)
		self.promises[command] = promise
	else
		promise.done = true
	end

	return promise
end

function CommandSequencer:update()
	for i = #self.commands, 1, -1 do
		local command = self.commands[i]

		coroutine.resume(command)

		if (coroutine.status(command) == "dead") then
			table.remove(self.commands, i)
			self.promises[command].done = true
			self.promises[command] = nil
		end
	end

	for i = #self.enqueuedCommands, 1, -1 do
		local command = self.enqueuedCommands[i]
		table.insert(self.commands, command)
		self.enqueuedCommands[i] = nil
	end
end

return CommandSequencer